# models/transaction.py
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class ToolTransaction(BaseModel):
    id: Optional[str] = None
    userId: str
    toolId: str
    timestamp: datetime
    action: str

    class Config:
        extra = "ignore"
