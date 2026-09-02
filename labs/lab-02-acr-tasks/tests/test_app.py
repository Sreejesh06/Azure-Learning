from fastapi.testclient import TestClient
from app import app

client = TestClient(app)

def test_health_check():
    """Verify health endpoint returns 200 and healthy status."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_predict_valid_prompt():
    """Verify predict endpoint returns simulated inference response."""
    payload = {"prompt": "Explain ACR Tasks", "temperature": 0.5}
    response = client.post("/predict", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["prompt"] == "Explain ACR Tasks"
    assert "Simulated AI response" in data["reply"]

def test_predict_empty_prompt():
    """Verify empty prompt returns 400 bad request."""
    payload = {"prompt": "   "}
    response = client.post("/predict", json=payload)
    assert response.status_code == 400
