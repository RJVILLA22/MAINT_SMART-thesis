import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("maint-smart-firebase-adminsdk-fbsvc-fa0d09bb0b.json")
firebase_admin.initialize_app(cred)

db = firestore.client()