from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from sse_starlette.sse import EventSourceResponse
from datetime import datetime, timezone
import asyncio
import uvicorn

from mcp1 import mcp  # Import your registered MCP tools
from schema import (
    HashLookupInput, IOCSubmitInput, IOCStatusInput, IOCResultsInput,
    ErrorOutput, IOCSubmitOutput, IOCStatusOutput
)
from evidence import get_evidence

# ─── FastAPI Setup ─────────────────────────────────────────────────────────────

app = FastAPI(title="MCP Tools API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Adjust for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── REST Endpoints ────────────────────────────────────────────────────────────

@app.post("/tools/hash_lookup")
async def api_hash_lookup(input: HashLookupInput):
    try:
        result = mcp.tools["hash_lookup"](input)
        return result.model_dump() if hasattr(result, "model_dump") else result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/tools/ioc_submit")
async def api_ioc_submit(input: IOCSubmitInput):
    try:
        result = mcp.tools["ioc_submit"](input)
        return result.model_dump() if hasattr(result, "model_dump") else result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/tools/ioc_status")
async def api_ioc_status(input: IOCStatusInput):
    try:
        result = mcp.tools["ioc_status"](input)
        return result.model_dump() if hasattr(result, "model_dump") else result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/tools/ioc_results")
async def api_ioc_results(input: IOCResultsInput):
    try:
        result = mcp.tools["ioc_results"](input)
        return result if isinstance(result, dict) else result.model_dump()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ✅ FIXED: Tool Listing for Langflow
@app.get("/tools/list")
async def list_tools():
    return {
        "available_tools": [
            {
                "name": name,
                "description": func.__doc__ or "No description provided"
            }
            for name, func in mcp.tools.items()
        ]
    }

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "version": "1.0.0"
    }

@app.get("/")
async def root():
    return {
        "name": "MCP Tools API",
        "version": app.version,
        "description": app.description,
        "endpoints": {
            "hash_lookup": "/tools/hash_lookup",
            "ioc_submit": "/tools/ioc_submit",
            "ioc_status": "/tools/ioc_status",
            "ioc_results": "/tools/ioc_results",
            "tools_list": "/tools/list",
            "health": "/health",
            "sse": "/sse",
            "docs": "/docs",
            "redoc": "/redoc"
        }
    }

# ─── SSE Endpoint for Langflow ─────────────────────────────────────────────────

@app.get("/sse")
async def stream_job_status(request: Request):
    async def event_generator():
        while True:
            if await request.is_disconnected():
                break

            job = get_evidence(source="ioc_submit", query={})
            if job:
                yield {
                    "event": "update",
                    "data": {
                        "job_id": job["data"].get("job_id"),
                        "status": job["data"].get("status"),
                        "progress": job["data"].get("progress", 0.0),
                        "timestamp": datetime.now(timezone.utc).isoformat()
                    }
                }
            await asyncio.sleep(2)

    return EventSourceResponse(event_generator())

# ─── Entrypoint ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=3001)
