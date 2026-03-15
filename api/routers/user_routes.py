from fastapi import APIRouter
from firebase import db
from models.user import AppUser
from typing import List, Dict

router = APIRouter(tags=["User APIs"])

user_ref = db.collection("users")

@router.get("/users/students", response_model=List[AppUser])
def get_all_students():
    docs = user_ref.where("type", "==", "student").stream()

    users = []
    for doc in docs:
        data = doc.to_dict()
        data.pop("id", None)   
        users.append(AppUser(id=doc.id, **data))

    return users


@router.get("/users/instructors", response_model=List[AppUser])
def get_all_instructors():
    docs = user_ref.where("type", "==", "instructor").stream()

    users = []
    for doc in docs:
        data = doc.to_dict()
        data.pop("id", None)   
        users.append(AppUser(id=doc.id, **data))

    return users
@router.get("/users/grouped", response_model=Dict[str, List[AppUser]])
def get_all_users_grouped():
    docs = user_ref.stream()

    students = []
    instructors = []

    for doc in docs:
        data = doc.to_dict()
        data.pop("id", None)
        user = AppUser(id=doc.id, **data)

        if user.type.lower() == "student":
            students.append(user)
        elif user.type.lower() == "instructor":
            instructors.append(user)

    return {
        "students": students,
        "instructors": instructors,
    }
