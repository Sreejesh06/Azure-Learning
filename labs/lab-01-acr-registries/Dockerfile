# Layer 1: Base Linux OS + Python runtime (~130MB)
FROM python:3.11-slim

# Layer 2: Metadata / working directory
WORKDIR /app

# Layer 3: Dependency manifest
COPY requirements.txt .

# Layer 4: Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Layer 5: Application code
COPY app.py .

EXPOSE 8080
CMD ["python", "app.py"]
