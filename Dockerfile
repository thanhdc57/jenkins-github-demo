FROM python:3.12-slim AS base

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY test_app.py .


FROM base AS test

CMD ["pytest", "-v"]


FROM base AS runtime

EXPOSE 5000

CMD ["python", "app.py"]