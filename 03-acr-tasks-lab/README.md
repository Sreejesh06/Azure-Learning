# ACR Tasks Hands-On Practice Lab

This lab contains the complete code structure and commands covered in the **"Build and run images with ACR Tasks"** Microsoft Learn module.

---

## 📁 File Structure & Concepts

| File | Role & Concept |
| :--- | :--- |
| [`app.py`](app.py) | Sample FastAPI AI inference microservice (`/health`, `/predict`). |
| [`requirements.txt`](requirements.txt) | Python dependencies (`fastapi`, `uvicorn`, `pydantic`, `pytest`). |
| [`tests/test_app.py`](tests/test_app.py) | Unit tests used during multi-step build validation. |
| [`.dockerignore`](.dockerignore) | Excludes `.venv`, `.git`, caches to minimize upload context size. |
| [`Dockerfile`](Dockerfile) | Multi-layer Dockerfile optimized for ACR layer caching & base image triggers. |
| [`acr-task.yaml`](acr-task.yaml) | Multi-step task definition: **Build ➔ Pytest ➔ Push**. |
| [`commands_cheatsheet.sh`](commands_cheatsheet.sh) | All `az acr build`, `az acr task create`, and `az acr run` commands. |

---

## 🚀 Quick Reference Commands

### 1. Quick Task (Instant Cloud Build)
```bash
az acr build --registry <your-acr-name> --image inference-api:v1.0.0 .
```

### 2. Run Multi-Step Task Workflow (`acr-task.yaml`)
```bash
az acr run --registry <your-acr-name> --file acr-task.yaml .
```

### 3. Smoke Test Image in the Cloud (`az acr run`)
```bash
az acr run --registry <your-acr-name> --cmd '$Registry/inference-api:v1.0.0 python --version' /dev/null
```
