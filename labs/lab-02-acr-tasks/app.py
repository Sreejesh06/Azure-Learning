from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import sys

app = FastAPI(
    title="Azure AI Inference API",
    description="Sample AI microservice for ACR Tasks practice",
    version="1.0.0"
)

class InferenceRequest(BaseModel):
    prompt: str
    temperature: float = 0.7

class InferenceResponse(BaseModel):
    prompt: str
    reply: str
    model_version: str

@app.get("/health")
def health_check():
    """Liveness & Readiness probe endpoint for Azure Container Apps."""
    return {"status": "healthy", "python_version": sys.version}

@app.post("/predict", response_model=InferenceResponse)
def predict(request: InferenceRequest):
    """Simulated AI model inference endpoint."""
    if not request.prompt.strip():
        raise HTTPException(status_code=400, detail="Prompt cannot be empty.")
    
    # In real deployment, this calls Azure AI Foundry / Azure OpenAI
    return InferenceResponse(
        prompt=request.prompt,
        reply=f"Simulated AI response for: '{request.prompt}' (temp: {request.temperature})",
        model_version="gpt-4o-2026"
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
