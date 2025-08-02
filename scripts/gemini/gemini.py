#!/usr/bin/env /home/nitish/virtualenv/gemini/bin/python3
import os
import sys
import json
import requests

API_KEY = os.getenv("GEMINI_API_KEY")
MODEL = os.getenv("GEMINI_MODEL", "gemini-2.0-flash")
BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models"

if not API_KEY:
    print("Error: Please export GEMINI_API_KEY first.")
    sys.exit(1)

if len(sys.argv) < 2:
    print("Usage: gemini.py 'your prompt here'")
    sys.exit(1)

prompt = " ".join(sys.argv[1:])

url = f"{BASE_URL}/{MODEL}:generateContent?key={API_KEY}"
payload = {
    "contents": [
        {
            "parts": [{"text": prompt}]
        }
    ]
}

resp = requests.post(url, headers={"Content-Type": "application/json"}, json=payload)
if resp.status_code != 200:
    print("Error:", resp.status_code, resp.text)
    sys.exit(1)

data = resp.json()
try:
    print(data["candidates"][0]["content"]["parts"][0]["text"])
except (KeyError, IndexError):
    print(json.dumps(data, indent=2))

