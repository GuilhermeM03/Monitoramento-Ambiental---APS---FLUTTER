# main.py atualizado com geolocalização automática por cidade
from fastapi import FastAPI, Query, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional
from .schemas import MetricsResponse, Weather, AirQuality, Pollutant
from .services import fetch_weather, fetch_air_quality
from dotenv import load_dotenv
from pathlib import Path
import os
import httpx

# Carregar o .env a partir da pasta "backend"
env_path = Path(__file__).resolve().parent.parent / '.env'
load_dotenv(dotenv_path=env_path)

print("OWM_API_KEY:", "OK" if os.getenv("OWM_API_KEY") else "❌ MISSING")
print("AIRVISUAL_API_KEY:", "OK" if os.getenv("AIRVISUAL_API_KEY") else "❌ MISSING")

app = FastAPI(title="Env Monitor API", version="1.4.0")

# Middleware para liberar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health():
    return {"status": "ok"}


async def get_client_location(request: Request) -> Optional[dict]:
    """Obtém a geolocalização do IP público do cliente."""
    client_ip = request.client.host
    try:
        async with httpx.AsyncClient(timeout=10) as client:
            r = await client.get(f"https://ipapi.co/{client_ip}/json/")
            if r.status_code == 200:
                data = r.json()
                return {
                    "lat": data.get("latitude"),
                    "lon": data.get("longitude"),
                    "city": data.get("city"),
                    "state": data.get("region"),
                    "country": data.get("country_name"),
                }
    except Exception as e:
        print(f"[WARN] Falha ao obter geolocalização automática: {e}")
    return None


@app.get("/api/metrics", response_model=MetricsResponse)
async def get_metrics(
    request: Request,
    city: Optional[str] = Query(None, description="City name, e.g. 'São Paulo'"),
    state: Optional[str] = Query(None, description="State name, e.g. 'São Paulo'"),
    country: Optional[str] = Query(None, description="Country name, e.g. 'Brazil'"),
    lat: Optional[float] = Query(None, description="Latitude"),
    lon: Optional[float] = Query(None, description="Longitude"),
):
    try:
        # Se nenhum dado for informado, tenta obter via IP
        if not any([lat, lon, city]):
            geo = await get_client_location(request)
            if geo:
                lat = geo["lat"]
                lon = geo["lon"]
                city = geo["city"]
                state = geo["state"]
                country = geo["country"]
                print(f"[INFO] Localização detectada: {city}, {state}, {country}")

        # Se apenas city for informado, tentar obter coordenadas automaticamente
        if city and not (lat and lon):
            try:
                weather_lookup = await fetch_weather(city=city)
                coord = weather_lookup.get("coord", {})
                lat = coord.get("lat")
                lon = coord.get("lon")
                country = weather_lookup.get("sys", {}).get("country")
                state = city  # fallback simples (pode ser aprimorado)
                print(f"[INFO] Coordenadas obtidas automaticamente: {lat}, {lon} ({country})")
            except Exception as e:
                print(f"[WARN] Falha ao obter coordenadas para cidade '{city}': {e}")

        # Busca os dados climáticos e de poluição
        if lat is not None and lon is not None:
            weather_raw = await fetch_weather(lat=lat, lon=lon)
            air_raw = await fetch_air_quality(lat=lat, lon=lon)
        elif city and state and country:
            weather_raw = await fetch_weather(city=city)
            air_raw = await fetch_air_quality(city=city, state=state, country=country)
        else:
            raise HTTPException(status_code=400, detail="Provide either (lat, lon) or (city, state, country)")

        # Parse clima
        weather = Weather(
            temperature=weather_raw.get("main", {}).get("temp"),
            humidity=weather_raw.get("main", {}).get("humidity"),
            description=(weather_raw.get("weather") or [{}])[0].get("description"),
            icon=(weather_raw.get("weather") or [{}])[0].get("icon"),
        )

        # Parse qualidade do ar (AirVisual)
        data = air_raw.get("data", {})
        pollutants = []
        loc = data.get("city")
        coords = None

        if data.get("location") and data.get("current", {}).get("pollution"):
            pollution = data["current"]["pollution"]
            coords = {
                "latitude": data["location"]["coordinates"][1],
                "longitude": data["location"]["coordinates"][0],
            }
            pollutants = [
                Pollutant(parameter="AQI", value=float(pollution.get("aqius")), unit="US AQI"),
                Pollutant(parameter=pollution.get("mainus").upper(), value=0.0, unit="Dominant pollutant")
            ]

        air = AirQuality(location=loc, coordinates=coords, pollutants=pollutants)

        return MetricsResponse(
            city=city or weather_raw.get("name"),
            country=country,
            weather=weather,
            air_quality=air,
        )

    except HTTPException:
        raise
    except Exception as e:
        print(f"[ERROR] /api/metrics -> {e}")
        raise HTTPException(status_code=500, detail=str(e))