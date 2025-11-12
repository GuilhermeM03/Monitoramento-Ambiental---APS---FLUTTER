# Backend (FastAPI)

Endpoints:
- `GET /health`
- `GET /api/metrics?city=São Paulo&country=BR` or `GET /api/metrics?lat=-23.55&lon=-46.63`

## Run with Docker
1. Copy `.env.example` to `.env` and add your keys.
2. From the project root: `docker compose up --build -d`
3. API available at `http://localhost:8000`
4. Docs: `http://localhost:8000/docs`

## Environment Variables
- `OWM_API_KEY`: OpenWeatherMap API key
- `OPENAQ_BASE_URL`: defaults to `https://api.airvisual.com/v2`
