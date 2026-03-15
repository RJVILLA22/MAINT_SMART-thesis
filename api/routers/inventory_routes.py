
from typing import Optional
from fastapi import APIRouter, Query
from datetime import timedelta, datetime, time
from firebase import db
from google.cloud.firestore_v1 import FieldFilter

from models.tool import Tool
from models.transaction import ToolTransaction
from models.user import AppUser

router = APIRouter(prefix="/inventory", tags=["Inventory"])

tool_ref = db.collection("tools")
txn_ref = db.collection("transactions")
user_ref = db.collection("users")

@router.get("/borrowed/user/{user_id}")
def get_user_borrowed_tools(user_id: str):
    docs = (
        txn_ref.where("userId", "==", user_id)
        .order_by("timestamp", direction="DESCENDING")
        .stream()
    )

    latest_by_tool: dict[str, ToolTransaction] = {}

    # latest transaction per tool
    for doc in docs:
        data = doc.to_dict()
        data.pop("id", None)

        txn = ToolTransaction(id=doc.id, **data)

        if txn.toolId not in latest_by_tool:
            latest_by_tool[txn.toolId] = txn

    borrowed = []

    for txn in latest_by_tool.values():
        if txn.action != "borrow":
            continue

        tool_doc = tool_ref.document(txn.toolId).get()
        if not tool_doc.exists:
            continue

        tool_data = tool_doc.to_dict()
        tool_data.pop("id", None)

        tool = Tool(id=tool_doc.id, **tool_data)
        if tool.status == 'available':
            continue

        borrowed_at = txn.timestamp
        due_date = borrowed_at + timedelta(days=tool.borrowDays)

        borrowed.append({
            "model": tool.model,
            "borrowedAt": borrowed_at,
            "dueDate": due_date,
        })

    return borrowed


@router.get("/borrowed")
def get_all_borrowed_tools():
    docs = txn_ref.order_by("timestamp", direction="DESCENDING").stream()

    latest_by_tool: dict[str, ToolTransaction] = {}

    for doc in docs:
        data = doc.to_dict()
        data.pop("id", None)

        try:
            txn = ToolTransaction(id=doc.id, **data)
        except Exception:
            continue

        if txn.toolId not in latest_by_tool:
            latest_by_tool[txn.toolId] = txn

    borrowed = []

    for txn in latest_by_tool.values():
        if txn.action != "borrow":
            continue

        tool_doc = tool_ref.document(txn.toolId).get()
        user_doc = user_ref.document(txn.userId).get()

        if not tool_doc.exists or not user_doc.exists:
            continue

        tool_data = tool_doc.to_dict()
        user_data = user_doc.to_dict()

        tool_data.pop("id", None)
        user_data.pop("id", None)

        tool = Tool(id=tool_doc.id, **tool_data)
        user = AppUser(id=user_doc.id, **user_data)

        borrowed_at = txn.timestamp
        due_date = borrowed_at + timedelta(days=tool.borrowDays)

        borrowed.append({
            "model": tool.model,
            "id": user.id,
            "borrowedBy": user.id_number or user.email,
            "borrowedAt": borrowed_at,
            "dueDate": due_date,
        })

    return borrowed
@router.get("/tools/available")
def get_available_tools():
    docs = tool_ref.where("status", "==", "available").stream()

    tools = []

    for doc in docs:
        data = doc.to_dict()
        data.pop("id", None)

        tool = Tool(id=doc.id, **data)

        tools.append({
            "id": tool.id,
            "model": tool.model,
            "description": tool.description or "",
            "borrowDays": tool.borrowDays,
        })

    return tools

@router.get("/tools")
def get_all_tools():
    docs = tool_ref.stream()

    tools = []

    for doc in docs:
        data = doc.to_dict()
        data.pop("id", None)

        tool = Tool(id=doc.id, **data)

        tools.append({
            "id": tool.id,
            "model": tool.model,
            "description": tool.description or "",
            "borrowDays": tool.borrowDays,
            "status": tool.status,
        })

    return tools

@router.get("/tools/search")
def search_tools(keyword: str):
    keyword = keyword.lower()
    docs = tool_ref.stream()

    results = []

    for doc in docs:
        data = doc.to_dict()
        data.pop("id", None)

        tool = Tool(id=doc.id, **data)

        if (
            keyword in tool.model.lower()
            or keyword in (tool.description or "").lower()
        ):
            results.append({
                "model": tool.model,
                "description": tool.description or "",
                "borrowDays": tool.borrowDays,
                "status": tool.status,
            })

    return results


@router.get("/history")
def get_borrow_history(
    start: datetime = Query(...),
    end: datetime = Query(...)
):
    """
    Returns borrow history within a date range.
    Includes returnedAt if the tool was returned.
    """

    # We only care about transactions inside the date window
    start_dt = datetime.combine(start, time.min).isoformat()
    end_dt   = datetime.combine(end, time.max).isoformat()

    query = (
        txn_ref
        .where(filter=FieldFilter("timestamp", ">=", start_dt))
        .where(filter=FieldFilter("timestamp", "<=", end_dt))
        .order_by("timestamp")
    )

    docs = query.stream()
    # docs = txn_ref.order_by("timestamp", direction="DESCENDING").stream()


    # Key: (toolId, userId)
    grouped: dict[tuple[str, str], list[ToolTransaction]] = {}

    for doc in docs:
        print("here")
        data = doc.to_dict()
        data.pop("id", None)
        print(data)


        txn = ToolTransaction(id=doc.id, **data)

        key = (txn.toolId, txn.userId)

        grouped.setdefault(key, []).append(txn)

    results = []

    for (tool_id, user_id), txns in grouped.items():

        # sort by time just in case
        txns.sort(key=lambda x: x.timestamp)

        # find borrow transactions in this group
        for i, txn in enumerate(txns):

            if txn.action != "borrow":
                continue

            borrowed_at = txn.timestamp
            returned_at: Optional[datetime] = None

            # find the next return after this borrow
            for later in txns[i + 1:]:
                if later.action == "return":
                    returned_at = later.timestamp
                    break

            # load user
            user_doc = user_ref.document(user_id).get()
            if not user_doc.exists:
                continue

            user_data = user_doc.to_dict()
            user_data.pop("id", None)
            user = AppUser(id=user_doc.id, **user_data)

            # load tool
            tool_doc = tool_ref.document(tool_id).get()
            if not tool_doc.exists:
                continue

            tool_data = tool_doc.to_dict()
            tool_data.pop("id", None)
            tool = Tool(id=tool_doc.id, **tool_data)

            borrower_name = f"{user.first_name} {user.last_name}"

            results.append({
                "borrower": borrower_name,
                "tool": tool.model,
                "borrowedAt": borrowed_at,
                "returnedAt": returned_at,
                "description": tool.description,
                "status": tool.status,
                "classification": user.type
            })

    return results

