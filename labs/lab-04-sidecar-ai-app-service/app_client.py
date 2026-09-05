import asyncio
from pathlib import Path
import httpx

# ======================================================
# LAB 04: Inter-Container Networking & Shared File Volume
# ======================================================

# 1. Local Sidecar Endpoint (Shared Network Namespace)
MODEL_ENDPOINT = "http://localhost:11434/v1/chat/completions"
HEALTH_ENDPOINT = "http://localhost:11434/health"

# 2. Shared Volume Directory (Built-in /home mount)
SHARED_DIR = Path("/home/models")


async def check_model_health() -> str:
    """
    Classifies local sidecar health status into 3 distinct diagnostic categories:
    - 'ready': Sidecar is listening and healthy.
    - 'connect-error': Sidecar process crashed or isn't listening on target port.
    - 'timeout': Sidecar is frozen, loading weights into memory, or overburdened.
    - 'http-<code'>: Sidecar returned HTTP status error (e.g. 500/400).
    """
    try:
        async with httpx.AsyncClient(timeout=2.0) as client:
            response = await client.get(HEALTH_ENDPOINT)
            response.raise_for_status()
            return "ready"
    except httpx.ConnectError:
        print("[DIAGNOSTIC] ConnectError: Process is not listening on port 11434.")
        return "connect-error"
    except httpx.TimeoutException:
        print("[DIAGNOSTIC] TimeoutException: Request exceeded 2s connect/read timeout.")
        return "timeout"
    except httpx.HTTPStatusError as error:
        print(f"[DIAGNOSTIC] HTTPStatusError: Sidecar returned status {error.response.status_code}.")
        return f"http-{error.response.status_code}"


async def request_model_completion(messages: list[dict[str, str]]) -> dict:
    """
    Sends a completion request to the local AI model sidecar container.
    Enforces a 2.0s connection timeout and a 30s overall request deadline.
    """
    timeout = httpx.Timeout(10.0, connect=2.0)
    
    try:
        async with httpx.AsyncClient(timeout=timeout) as client:
            async with asyncio.timeout(30.0):
                response = await client.post(
                    MODEL_ENDPOINT,
                    json={
                        "model": "phi-3-mini-instruct",
                        "messages": messages
                    }
                )
                response.raise_for_status()
                return response.json()
    except TimeoutError:
        print("[ERROR] Request exceeded overall 30-second deadline.")
        raise
    except httpx.ConnectTimeout:
        print("[ERROR] Could not connect to sidecar on http://localhost:11434 within 2s.")
        raise
    except httpx.HTTPStatusError as exc:
        print(f"[ERROR] Model sidecar returned HTTP status error: {exc.response.status_code}")
        raise


def write_manifest_atomically(manifest_data: str) -> Path:
    """
    Writes manifest data to /home/models/manifest.json using the atomic rename pattern.
    Prevents reader processes from reading partially written files.
    """
    SHARED_DIR.mkdir(parents=True, exist_ok=True)
    
    temp_file = SHARED_DIR / "manifest.json.tmp"
    final_file = SHARED_DIR / "manifest.json"
    
    temp_file.write_text(manifest_data, encoding="utf-8")
    temp_file.replace(final_file)
    print(f"[SUCCESS] Atomically wrote manifest to {final_file}")
    return final_file


def read_manifest() -> str:
    """Reads the model manifest file from the shared /home/models directory."""
    manifest_file = SHARED_DIR / "manifest.json"
    if not manifest_file.exists():
        raise FileNotFoundError(f"Manifest file not found at {manifest_file}")
    
    return manifest_file.read_text(encoding="utf-8")


if __name__ == "__main__":
    print("=== Testing Health Check Diagnostics ===")
    health = asyncio.run(check_model_health())
    print("Sidecar Health Status:", health)

    print("\n=== Testing Atomic File Write ===")
    write_manifest_atomically('{"model": "phi-3-mini-instruct", "status": "ready"}')
    print("Read Manifest Content:", read_manifest())
