import os
import json
import google.generativeai as genai
from pymongo import MongoClient
from bson.objectid import ObjectId # Important: To query by MongoDB's _id

# --- SCRIPT CONFIGURATION ---


API_KEY = "AIzaSyCYM-C6FUgqH6LvlExVdqWjb1LGPkWJUaU"


MONGO_CONNECTION_STRING = "mongodb://localhost:27017/"
MONGO_DB_NAME = "mcp_enrichment"
MONGO_COLLECTION_NAME = "evidence"
DOCUMENT_ID_TO_FETCH = "68cf92e7ad0abb042e7c716b" 


def fetch_ioc_from_mongodb(conn_str, db_name, collection_name, doc_id):
    """Connects to MongoDB and fetches a single IOC document by its ID."""
    print(f"Connecting to MongoDB database: '{db_name}'...")
    try:
        client = MongoClient(conn_str)
        db = client[db_name]
        collection = db[collection_name]
        
  
        object_id = ObjectId(doc_id)
        
        print(f"Fetching document with _id: {doc_id}...")
        document = collection.find_one({"_id": object_id})
        
        client.close() 
        return document
    except Exception as e:
        print(f" Error connecting to or fetching from MongoDB: {e}")
        return None

def generate_threat_report(ioc_data: dict, api_key: str) -> str:
    """Generates a threat report by sending IOC data to the Gemini model."""
    try:
        if not api_key or api_key == "YOUR_API_KEY_HERE":
            raise ValueError("🔴 API key not provided. Please set the API_KEY variable.")
        genai.configure(api_key=api_key)

        model = genai.GenerativeModel('gemini-1.5-flash-latest')

        
        ioc_json_string = json.dumps(ioc_data, indent=2, default=str)

        prompt = f"""
        You are a senior cybersecurity analyst. Your task is to write a threat intelligence report
        based on the following enriched IOC data provided in JSON format, fetched from a database.

        The report must be clear, concise, and actionable for a security team.

        Structure the report with these sections:
        1.  **Executive Summary:** A high-level overview of the threat and its severity.
        2.  **Indicator Details:** A table summarizing the primary IOC.
        3.  **Detailed Enrichment Analysis:** Summarize findings from each source (VirusTotal, ThreatFox, etc.).
        4.  **Analyst Notes & Discrepancies:** Highlight any conflicting data (like incorrect tags) and provide context on the malware.
        5.  **Actionable Recommendations:** Provide a numbered list of concrete steps for remediation.

        Here is the IOC data:
        ```json
        {ioc_json_string}
        ```
        """
        response = model.generate_content(prompt)
        return response.text

    except Exception as e:
        return f"An error occurred: {e}"

if __name__ == "__main__":
   
    ioc_document = fetch_ioc_from_mongodb(
        MONGO_CONNECTION_STRING,
        MONGO_DB_NAME,
        MONGO_COLLECTION_NAME,
        DOCUMENT_ID_TO_FETCH
    )
    
    if ioc_document:
        print("Document fetched successfully.")
        print("Starting threat report generation...")
        
      
        report = generate_threat_report(ioc_document, API_KEY)
        
        print("\n" + "="*50)
        print("📄 Generated Threat Intelligence Report")
        print("="*50 + "\n")
        print(report)
    else:
        print("Could not generate report because the document could not be fetched.")