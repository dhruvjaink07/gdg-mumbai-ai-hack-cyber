import os
import json
from datetime import datetime,timezone
from typing import Dict, Optional

# Optional MongoDB support
try:
    from pymongo import MongoClient
    mongo_client = MongoClient("mongodb://localhost:27017")
    db = mongo_client["mcp_enrichment"]
    collection = db["evidence"]
    USE_MONGO = True
except Exception:
    USE_MONGO = False

# ─── Store Evidence ─────────────────────────────────────────────────────────────

def store_evidence(ioc: str, source: str, data: Dict):
    timestamp = datetime.now(timezone.utc).isoformat()
    record = {
        "ioc": ioc,
        "source": source,
        "timestamp": timestamp,
        "data": data
    }

    if USE_MONGO:
        collection.insert_one(record)
    else:
        os.makedirs("evidence", exist_ok=True)
        filename = f"evidence/{ioc}_{source}.json"
        with open(filename, "w") as f:
            json.dump(record, f, indent=2, default=str)

# ─── Get Evidence ───────────────────────────────────────────────────────────────

def get_evidence(source: str, query: Dict) -> Optional[Dict]:
    if USE_MONGO:
        return collection.find_one({
            "source": source,
            **{f"data.{k}": v for k, v in query.items()}
        })
    else:
        ioc = query.get("ioc")
        if not ioc:
            return None
        filename = f"evidence/{ioc}_{source}.json"
        if not os.path.exists(filename):
            return None
        with open(filename) as f:
            return json.load(f)
