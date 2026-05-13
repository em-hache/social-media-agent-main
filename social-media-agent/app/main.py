# social-media-agent/app/main.py
from fastapi import FastAPI
from contextlib import asynccontextmanager
from .config import settings
from .db import engine, Base
from .dynamo import get_dynamo_client
from .routers import items

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    # Shutdown
    await engine.dispose()

app = FastAPI(title="FastAPI Service", version="1.0.0", lifespan=lifespan)
app.include_router(items.router, prefix="/items", tags=["items"])

@app.get("/health")
async def health():
    return {"status": "ok", "service": "social-media-agent"}
