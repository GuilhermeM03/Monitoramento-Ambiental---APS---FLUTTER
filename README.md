# Monitoramento Ambiental (Mobile + API + Docker)

Atende aos requisitos da APS de DSD: app **mobile (Flutter)**, **Web Service Intermediário (FastAPI)** e consumo de **Web Service API Destino** (OpenWeatherMap + OpenAQ). Também inclui **Docker** para o backend.

## Passo a passo rápido
1. Copie `backend/.env.example` para `backend/.env` e informe `OWM_API_KEY` (OpenWeatherMap).
2. `docker compose up --build -d`
3. Rode o app Flutter em `mobile_flutter`.

## APIs de terceiros usadas
- OpenWeatherMap (tempo/umidade/temperatura)
- OpenAQ (poluentes)

> Dica: para testes, use a cidade *São Paulo, BR*.

## Estrutura
- `backend/` (FastAPI + Dockerfile)
- `mobile_flutter/` (Flutter)
- `docker-compose.yml`

## Documentação/Swagger
Depois de subir: `http://localhost:8000/docs`
