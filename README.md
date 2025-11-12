# Monitoramento Ambiental (Mobile + API + Docker)

Atende aos requisitos da APS de DSD: app **mobile (Flutter)**, **Web Service Intermediário (FastAPI)** e consumo de **Web Service API Destino** (OpenWeatherMap + OpenAQ). Também inclui **Docker** para o backend.

## Passo a passo rápido
1. No Prompt de Comando navegue até o diretório onde está o docker-compose.yml `cd "C:\caminho\para\Monitoramento Ambiental - APS"`
2. Construa os containers `docker-compose build`
3. Suba os containers `docker-compose up`.

## APIs de terceiros usadas
- OpenWeatherMap (tempo/umidade/temperatura)
- IQAir (poluentes)

> Dica: para testes, use a cidade *São Paulo*.

## Estrutura
- `backend/` (FastAPI + Dockerfile)
- `mobile_flutter/` (Flutter)
- `docker-compose.yml`

## Documentação/Swagger
Depois de subir acesse:

Aplicativo: `http://localhost:8080`
Backend: `http://localhost:8000/docs`
