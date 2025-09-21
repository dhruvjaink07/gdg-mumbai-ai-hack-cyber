from mcp.server.fastmcp import FastMCP
import os
import json
import requests
from dotenv import load_dotenv
from datetime import datetime,timezone,timedelta
from schema import (
    HashLookupInput, HashLookupOutput, IOCSubmitInput, IOCStatusInput, IOCStatusOutput,
    IOCResultsInput, SandboxSubmitInput, SandboxResultsInput, YaraScanInput,
    MISPQueryInput, ThreatIntelIPInput, ErrorOutput, IOCSubmitOutput, SandboxSubmitOutput
)
from validation import is_valid_hash
from evidence import store_evidence,get_evidence
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import HumanMessage
import os
import json
from datetime import datetime, timezone
from schema import IOCResultsInput, ErrorOutput
from evidence import get_evidence
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import HumanMessage
from dotenv import load_dotenv

load_dotenv()
GEMINI_API_KEY ="AIzaSyCYM-C6FUgqH6LvlExVdqWjb1LGPkWJUaU"

gemini = ChatGoogleGenerativeAI(
    model="gemini-2.0-flash",
    google_api_key=GEMINI_API_KEY,
    temperature=0.4
)

# Load environment variables
load_dotenv()

# Configuration from environment variables
VT_API_KEY = os.getenv('VIRUSTOTAL_API_KEY')
MB_API_KEY = os.getenv('MALWAREBAZAAR_API_KEY')
THREATFOX_API_KEY = os.getenv('THREATFOX_API_KEY')
MISP_API_KEY = os.getenv('MISP_API_KEY')
SANDBOX_API_KEY = os.getenv('SANDBOX_API_KEY')

# Validate required API keys
def validate_api_keys():
    required_keys = {
        'VIRUSTOTAL_API_KEY': VT_API_KEY,
        'MALWAREBAZAAR_API_KEY': MB_API_KEY,
        'THREATFOX_API_KEY': THREATFOX_API_KEY,
        'MISP_API_KEY': MISP_API_KEY,
        'SANDBOX_API_KEY': SANDBOX_API_KEY
    }
    
    missing_keys = [key for key, value in required_keys.items() if not value]
    if missing_keys:
        raise EnvironmentError(f"Missing required API keys: {', '.join(missing_keys)}")

def summarize_hash_lookup(data: dict, ioc: str) -> dict:
    try:
        payload = json.dumps(data, indent=2)
        prompt = f"""
You are a malware analyst and SOC triage expert. Review the following hash-based enrichment data for IOC {ioc}:

{payload}

Return a single JSON object with:
{{
    "summary": "3–5 sentence technical overview",
    "severity": "low/medium/high/critical",
    "confidence_score": "0–100",
    "threat_categories": ["list"],
    "malware_families": ["if", "identified"],
    "indicators": {{
        "behavioral": ["list"],
        "network": ["list"]
    }},
    "recommended_actions": ["prioritized", "list"],
    "triage_summary": "Quick SOC assessment",
    "risk_level": "low/medium/high/critical",
    "immediate_actions": ["priority", "ordered", "list"],
    "playbook_recommendations": {{
        "containment": ["steps"],
        "investigation": ["steps"],
        "remediation": ["steps"]
    }},
    "escalation_recommendation": {{
        "should_escalate": boolean,
        "reason": "explanation",
        "recommended_team": "team name"
    }},
    "analysis_confidence": {{
        "factors_supporting": ["list"],
        "factors_uncertain": ["list"]
    }}
}}
"""
        response = gemini.invoke([HumanMessage(content=prompt)])
        return json.loads(response.content)

    except Exception as e:
        return {
            "error": str(e),
            "timestamp": datetime.now(timezone.utc).isoformat()
        }
    
# server = Server(name="mcp1")
mcp = FastMCP("mcp1")
# ─── Tools ─────────────────────────────────────────────────────────────────────

@mcp.tool(name="hash_lookup", description="Lookup hash in VT / MB / ThreatFox")
def hash_lookup(input: HashLookupInput) -> HashLookupOutput:
    if not is_valid_hash(input.hash):
        raise ValueError("Invalid hash format. Must be MD5 or SHA256.")

    try:
        # VirusTotal API Call
        vt_url = f"https://www.virustotal.com/api/v3/files/{input.hash}"
        vt_headers = {"x-apikey": VT_API_KEY}
        vt_response = requests.get(vt_url, headers=vt_headers)
        vt_data = vt_response.json()
        
        mb_url = "https://mb-api.abuse.ch/api/v1/"
        mb_headers = {
            "Content-Type": "application/x-www-form-urlencoded",
            "Auth-Key": MB_API_KEY
        }
        mb_data = {
            "query": "get_info",
            "hash": input.hash
        }
        mb_response = requests.post(mb_url, headers=mb_headers, data=mb_data)
        mb_data = mb_response.json()
        
        threatfox_url = "https://threatfox-api.abuse.ch/api/v1/"
        threatfox_headers = {
            "Content-Type": "application/x-www-form-urlencoded",
            "Auth-Key": THREATFOX_API_KEY
        }
        threatfox_data = {
            "query": "search_hash",
            "hash": input.hash
        }

        threatfox_response = requests.post(threatfox_url, headers=threatfox_headers, json=threatfox_data)
        if threatfox_response.status_code != 200:
            raise requests.RequestException(f"ThreatFox API returned {threatfox_response.status_code}: {threatfox_response.text}")
        try:
            threatfox_data = threatfox_response.json()
        except ValueError:
            raise requests.RequestException(f"ThreatFox API returned non-JSON: {threatfox_response.text}")

        threatfox_data = threatfox_response.json()
        first_match = threatfox_data.get("data", [{}])[0]
        # Normalize and combine results
        result = HashLookupOutput(
            hash=input.hash,
            vt={
                "malicious": vt_data.get("data", {}).get("attributes", {}).get("last_analysis_stats", {}),
                "names": vt_data.get("data", {}).get("attributes", {}).get("names", []),
                "type_description": vt_data.get("data", {}).get("attributes", {}).get("type_description", "")
            },
            mb = {
                "is_malware": mb_data.get("query_status", "") == "malware_found",
                "file_type": mb_data.get("data", [{}])[0].get("file_type", ""),
                "signature": mb_data.get("data", [{}])[0].get("signature", "")
            },
        
            threatfox = {
                "ioc": first_match.get("ioc", ""),
                "ioc_type": first_match.get("ioc_type", ""),
                "threat_type": first_match.get("threat_type", ""),
                "malware": first_match.get("malware", ""),
                "confidence_level": first_match.get("confidence_level", ""),
                "reference": first_match.get("reference", "")
            },
            scan_date=datetime.now(timezone.utc)
        )
        store_evidence(ioc=input.hash, source="hash_lookup", data=result.model_dump())
        return result
    
    except Exception as e:
        return ErrorOutput(
            error=str(e),
            error_code="API_ERROR",
            timestamp=datetime.now(timezone.utc)
        )

    

@mcp.tool(name="ioc_submit", description="Submit IOC for enrichment")
def ioc_submit(input: IOCSubmitInput) -> IOCSubmitOutput | ErrorOutput:
    try:
        if input.type not in ["ip", "domain", "hash", "url"]:
            raise ValueError(f"Invalid IOC type: {input.type}")

        job_id = f"{int(datetime.now(timezone.utc).timestamp())}_{input.ioc}"
        enrichment_tasks = {
            "ip": ["abuseipdb", "greynoise", "shodan"],
            "domain": ["passivetotal", "whois", "dns"],
            "hash": ["virustotal", "malwarebazaar", "threatfox"],
            "url": ["urlscan", "phishtank", "googlesafebrowsing"]
        }

        estimated_completion = datetime.now(timezone.utc) + timedelta(seconds=len(enrichment_tasks[input.type]) * 30)
        job_metadata = {
            "job_id": job_id,
            "ioc": input.ioc,
            "ioc_type": input.type,
            "tags": input.tags or [],
            "tasks": enrichment_tasks[input.type],
            "submission_time": datetime.now(timezone.utc),
            "status": "submitted",
            "progress": 0.0
        }

        store_evidence(ioc=input.ioc, source="ioc_submit", data=job_metadata)

        if input.type == "hash":
            result = hash_lookup(HashLookupInput(hash=input.ioc))

            if isinstance(result, ErrorOutput):
                job_metadata["status"] = "error"
                job_metadata["progress"] = 0.0
                job_metadata["error_message"] = result.error
            else:
                enrichment_data = result.model_dump()
                store_evidence(ioc=input.ioc, source="hash_lookup", data=enrichment_data)
                job_metadata["status"] = "completed"
                job_metadata["progress"] = 1.0
                job_metadata["enrichment"] = enrichment_data
    
            store_evidence(ioc=input.ioc, source="ioc_submit", data=job_metadata)
        

        return IOCSubmitOutput(
            job_id=job_id,
            status=job_metadata["status"],
            submission_time=job_metadata["submission_time"],
            estimated_completion=estimated_completion
        )

    except Exception as e:
        return ErrorOutput(
            error=str(e),
            error_code="SUBMISSION_ERROR",
            timestamp=datetime.now(timezone.utc)
        )




@mcp.tool(name="ioc_status", description="Check status of IOC enrichment job")
def ioc_status(input: IOCStatusInput) -> IOCStatusOutput | ErrorOutput:
    try:
        job_record = get_evidence(source="ioc_submit", query={"job_id": input.job_id})
        if not job_record:
            raise ValueError(f"Job ID not found: {input.job_id}")

        job_data = job_record["data"]
        status = job_data.get("status", "unknown")
        progress = float(job_data.get("progress", 0.0))
        submission_time = job_data.get("submission_time", datetime.now(timezone.utc))
        error = job_data.get("error_message", None)

        return IOCStatusOutput(
            job_id=input.job_id,
            status=status,
            progress=progress,
            last_update=datetime.now(timezone.utc),
            error_message=error,
            enrichment = job_data.get("enrichment", None)
        )
    
        

    except Exception as e:
        return ErrorOutput(
            error=str(e),
            error_code="STATUS_CHECK_ERROR",
            timestamp=datetime.now(timezone.utc)
        )

@mcp.tool(name="ioc_results", description="Summarize hash-based enrichment data using Gemini")
def ioc_results(input: IOCResultsInput) -> dict | ErrorOutput:
    try:
        job_record = get_evidence(source="ioc_submit", query={"job_id": input.job_id})
        if not job_record:
            raise ValueError(f"Job ID not found: {input.job_id}")

        job_data = job_record["data"]
        ioc = job_data.get("ioc")
        ioc_type = job_data.get("ioc_type")
        status = job_data.get("status", "unknown")
        error = job_data.get("error_message", None)

        hash_record = get_evidence(source="hash_lookup", query={"ioc": ioc})
        hash_data = hash_record["data"] if hash_record else {}

        gemini_report = summarize_hash_lookup(hash_data, ioc) if hash_data else {
            "error": "No hash-based enrichment data available.",
            "timestamp": datetime.now(timezone.utc).isoformat()
        }

        full_report = {
            "job_id": input.job_id,
            "ioc": ioc,
            "type": ioc_type,
            "status": status,
            "error": error,
            "hash_lookup": hash_data,
            "gemini_report": gemini_report,
            "last_updated": datetime.now(timezone.utc)
        }

        ioc_dir = os.path.join("output", ioc)
        os.makedirs(ioc_dir, exist_ok=True)
        filename = os.path.join(ioc_dir, "report.json")

        def convert(obj):
            if isinstance(obj, datetime):
                return obj.isoformat()
            return obj

        with open(filename, "w") as f:
            json.dump(full_report, f, indent=2, default=convert)

        return full_report

    except Exception as e:
        return ErrorOutput(
            error=str(e),
            error_code="RESULTS_ERROR",
            timestamp=datetime.now(timezone.utc)
        )



# ─── Run ───────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    mcp.run()
