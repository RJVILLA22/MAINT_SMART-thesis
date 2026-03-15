# models/user.py
from pydantic import BaseModel, EmailStr
from typing import Optional

class AppUser(BaseModel):
    id: Optional[str] = None
    last_name: str
    first_name: str
    id_number: Optional[str] = None
    department: Optional[str] = None
    course: Optional[str] = None
    type: str
    email: EmailStr

    class Config:
        extra = "ignore"   # 🔒 ignore unexpected Firestore fields
