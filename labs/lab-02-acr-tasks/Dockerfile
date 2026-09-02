# 1. Base image (Triggers automatic rebuilds when upstream image is patched)
FROM python:3.11-slim

# Prevent Python from writing .pyc files and buffer stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# 2. Layer Caching Strategy: Install dependencies first
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Copy application and tests
COPY app.py .
COPY tests/ ./tests/

# 4. Expose the port for container networking
EXPOSE 8000

# 5. Production entrypoint
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
