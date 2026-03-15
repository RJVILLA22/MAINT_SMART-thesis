# models/tool.py
from pydantic import BaseModel
from typing import Optional

class Tool(BaseModel):
    id: Optional[str] = None
    model: str
    borrowDays: int
    status: str
    borrowedBy: Optional[str] = None
    description: Optional[str] = None

    class Config:
        extra = "ignore"
