FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY kafka_gcp_credentials_server.py .

EXPOSE 14293

CMD ["python", "kafka_gcp_credentials_server.py"]