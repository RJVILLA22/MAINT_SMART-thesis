from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import user_routes, inventory_routes

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],   # allow all origins
    allow_credentials=True,
    allow_methods=["*"],   # allow all methods
    allow_headers=["*"],   # allow all headers
)

app.include_router(user_routes.router)
app.include_router(inventory_routes.router)
