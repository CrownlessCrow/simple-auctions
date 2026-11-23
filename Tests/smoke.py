"""API-/databastester mot en separat testinstans. Skapar påhittad data via HTTP.
Kör: python3 Tests/smoke.py [http://localhost:5000]
"""
import datetime as dt
import http.cookiejar
import json
import sys
import urllib.error
import urllib.request
import uuid

base = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:5000"

class Client:
    def __init__(self):
        self.opener = urllib.request.build_opener(
            urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))

    def request(self, method, path, body=None, expected=200):
        req = urllib.request.Request(base + path,
            data=json.dumps(body).encode() if body is not None else None,
            headers={"Content-Type": "application/json"}, method=method)
        try:
            response = self.opener.open(req, timeout=15)
        except urllib.error.HTTPError as error:
            response = error
        with response:
            raw = response.read().decode()
            assert response.status == expected, (method, path, response.status, expected, raw)
            return json.loads(raw) if raw else None

    def login(self, email):
        return self.request("POST", "/api/auth/login", {"email": email, "password": "TestPassword123!"})

anonymous, seller, buyer = Client(), Client(), Client()
suffix = uuid.uuid4().hex
seller_email, buyer_email = f"seller-{suffix}@example.test", f"buyer-{suffix}@example.test"
for client, email in [(seller, seller_email), (buyer, buyer_email)]:
    user = client.request("POST", "/api/users", {"email": email, "password": "TestPassword123!"}, 201)
    assert set(user) == {"id", "email"}  # Inga lösenordsfält i svar.
    client.login(email)
    assert client.request("GET", "/api/auth/login")["user"]["id"] == user["id"]
    assert client.request("GET", f"/api/users/{user['id']}") == user
seller.request("POST", "/api/users", {"email": seller_email.upper(), "password": "x"}, 409)
anonymous.request("GET", "/api/auth/login", expected=401)
anonymous.request("POST", "/api/auth/login", {"email": buyer_email, "password": "wrong"}, 401)
anonymous.request("POST", "/api/users", {"email": "invalid", "password": "x"}, 400)

def create(end=None):
    end = end or dt.datetime.now(dt.timezone.utc) + dt.timedelta(minutes=5)
    return seller.request("POST", "/api/auctions", {"name": "Test auction", "endTime": end.isoformat()}, 201)

anonymous.request("POST", "/api/auctions", {"name": "x", "endTime": "2030-01-01T12:00:00Z"}, 401)
seller.request("POST", "/api/auctions", {"name": " ", "endTime": "2030-01-01T12:00:00Z"}, 400)
seller.request("POST", "/api/auctions", {"name": "x", "endTime": "2000-01-01T12:00:00Z"}, 400)
a = create()
path = f"/api/auctions/{a['id']}"
assert anonymous.request("GET", path)["currentPrice"] is None
assert anonymous.request("GET", path)["winnerId"] is None
assert anonymous.request("GET", path + "/bids") == []
anonymous.request("POST", path + "/bids", {"amount": 1}, 401)
buyer.request("POST", path + "/bids", {"amount": 1.001}, 400)
first = buyer.request("POST", path + "/bids", {"amount": 0.01, "buyerId": 999, "time": "2000-01-01"}, 201)
assert first["buyerId"] == buyer.request("GET", "/api/auth/login")["user"]["id"]
assert first["time"].startswith(str(dt.datetime.now(dt.timezone.utc).year))
buyer.request("POST", path + "/bids", {"amount": 0.02}, 201)
assert [b["amount"] for b in anonymous.request("GET", path + "/bids")] == [0.02, 0.01]
assert any(item["id"] == a["id"] for item in anonymous.request("GET", "/api/auctions"))
for target in ("/api/auctions/2147483647", "/api/auctions/2147483647/bids"):
    anonymous.request("GET", target, expected=404)
buyer.request("POST", "/api/auctions/2147483647/bids", {"amount": 1}, 404)

buyer.request("DELETE", "/api/auth/login", expected=204)
buyer.request("GET", "/api/auth/login", expected=401)
buyer.request("POST", path + "/bids", {"amount": 3}, 401)
print("API tests passed: auth, CRUD subset, decimal validation and data effects.")
