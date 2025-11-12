# backend/Dockerfile
FROM python:3.11-slim

# variáveis de ambiente para não gerar .pyc e forçar buffer no stdout (logs)
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Copia apenas os arquivos necessários primeiro (cache de layer)
COPY requirements.txt .

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && apt-get purge -y --auto-remove build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copia o restante do código
COPY . .

# Expõe a porta usada pelo uvicorn
EXPOSE 8000

# Comando de execução
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
