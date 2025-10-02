from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import RedirectResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, HttpUrl
from typing import List, Optional
import asyncio
from .ddb import put_mapping, get_mapping

app = FastAPI()

# CORS (wide-open; narrow this in prod)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------- Models ----------
class BulkUrlRequest(BaseModel):
    urls: List[HttpUrl]

class UrlResult(BaseModel):
    url: str
    short: Optional[str] = None
    error: Optional[str] = None

class BulkUrlResponse(BaseModel):
    results: List[UrlResult]

# ---------- Health ----------
@app.get("/healthz")
def health():
    import time
    return {"status": "App is working! and so is lambda perms too finally! hopefully", "ts": int(time.time())}

# ---------- Single shorten ----------
@app.post("/shorten")
async def shorten(req: Request):
    body = await req.json()
    url = body.get("url")
    if not url:
        raise HTTPException(status_code=400, detail="url required")

    # run blocking DDB write off the event loop
    short = await asyncio.to_thread(put_mapping, str(url))
    return {"short": short, "url": url}

# ---------- Bulk shorten ----------
@app.post("/bulk-shorten", response_model=BulkUrlResponse)
async def bulk_shorten(payload: BulkUrlRequest):
    if not payload.urls:
        raise HTTPException(status_code=400, detail="No URLs provided")
    if len(payload.urls) > 100:
        raise HTTPException(status_code=413, detail="Too many URLs. Maximum is 100")

    async def process_url(u: HttpUrl) -> UrlResult:
        try:
            short_id = await asyncio.to_thread(put_mapping, str(u))
            return UrlResult(url=str(u), short=short_id)
        except Exception as e:
            return UrlResult(url=str(u), error=str(e))

    results = await asyncio.gather(*(process_url(u) for u in payload.urls))
    return BulkUrlResponse(results=results)

# ---------- Resolve ----------
@app.get("/{short_id}")
def resolve(short_id: str):
    item = get_mapping(short_id)
    if not item:
        raise HTTPException(status_code=404, detail="not found")
    return RedirectResponse(item["url"])
