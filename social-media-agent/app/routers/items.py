# social-media-agent/app/routers/items.py
from fastapi import APIRouter, Depends
from sqlalchemy import text
from ..db import get_db

router = APIRouter()

@router.get("/")
async def list_items(db=Depends(get_db)):
    result = await db.execute(text("SELECT * FROM items ORDER BY created_at DESC LIMIT 50"))
    rows = result.mappings().all()
    return [dict(r) for r in rows]
