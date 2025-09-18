FROM python:3.12-slim as build 
WORKDIR /app
COPY requirements.txt .
RUN pip install --prefix=/install -r requirements.txt

FROM python:3.12-slim
WORKDIR /app
COPY --from=build /install /usr/local

RUN useradd -r appuser
COPY . .
EXPOSE 8080
USER appuser
CMD python -m uvicorn src.main:app --host 0.0.0.0 --port 8080