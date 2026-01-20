import requests
import json

url = "http://localhost:8069/api/authenticate"
headers = {"Content-Type": "application/json"}

# Try Scenario 1: Raw JSON (REST style)
payload_raw = {
    "login": "guillemruano999@gmail.com", 
    "password": "1234", 
    "db": "Justflix"
}

# Try Scenario 2: JSON-RPC (Odoo style)
payload_rpc = {
    "jsonrpc": "2.0", 
    "method": "call", 
    "params": {
        "login": "guillemruano999@gmail.com", 
        "password": "1234", 
        "db": "Justflix"
    },
    "id": 1
}

# Also try with 'Administrator' as login just in case
payload_admin = {
    "login": "Administrator", 
    "password": "1234", 
    "db": "Justflix"
}

def test_auth(label, payload):
    print(f"\n--- Testing {label} ---")
    try:
        response = requests.post(url, data=json.dumps(payload), headers=headers)
        print(f"Status Code: {response.status_code}")
        print(f"Response Body: {response.text}")
    except Exception as e:
        print(f"Failed to connect: {e}")

test_auth("Raw JSON (Email)", payload_raw)
test_auth("JSON-RPC (Email)", payload_rpc)
test_auth("Raw JSON (Username)", payload_admin)
