# services.py atualizado (com normalização automática de strings)
from typing import Optional, Dict, Any
import os
import httpx
import unicodedata

OPENWEATHER_URL = "https://api.openweathermap.org/data/2.5/weather"


def normalize_str(text: str) -> str:
    """Remove acentos e normaliza para ASCII."""
    return ''.join(
        c for c in unicodedata.normalize('NFD', text)
        if unicodedata.category(c) != 'Mn'
    )


async def fetch_weather(
    city: Optional[str] = None,
    lat: Optional[float] = None,
    lon: Optional[float] = None,
    units: str = "metric",
    lang: str = "pt_br",
) -> Dict[str, Any]:
    """Busca clima atual do OpenWeatherMap por cidade ou coordenadas."""
    api_key = os.getenv("OWM_API_KEY")
    if not api_key:
        raise RuntimeError("OWM_API_KEY is not set")

    params = {"appid": api_key, "units": units, "lang": lang}
    if city:
        params["q"] = city
    elif lat is not None and lon is not None:
        params["lat"] = lat
        params["lon"] = lon
    else:
        raise ValueError("Provide either 'city' or both 'lat' and 'lon'.")

    async with httpx.AsyncClient(timeout=20) as client:
        r = await client.get(OPENWEATHER_URL, params=params)
        r.raise_for_status()
        return r.json()


async def fetch_air_quality(
    city: Optional[str] = None,
    state: Optional[str] = None,
    country: Optional[str] = None,
    lat: Optional[float] = None,
    lon: Optional[float] = None,
) -> Dict[str, Any]:
    """
    Busca dados de poluentes usando a API AirVisual (IQAir),
    com suporte a geolocalização (lat/lon) ou cidade/estado/país.
    """
    api_key = os.getenv("AIRVISUAL_API_KEY")
    if not api_key:
        raise RuntimeError("AIRVISUAL_API_KEY is not set")

    async with httpx.AsyncClient(timeout=20) as client:
        if lat is not None and lon is not None:
            url = "https://api.airvisual.com/v2/nearest_city"
            params = {"lat": lat, "lon": lon, "key": api_key}
        elif city and state and country:
            # Normalizar strings e corrigir país se for código
            city = normalize_str(city)
            state = normalize_str(state)
            if country.upper() == "BR":
                country = "Brazil"

            url = "https://api.airvisual.com/v2/city"
            params = {
                "city": city,
                "state": state,
                "country": country,
                "key": api_key
            }
        else:
            raise ValueError("Provide either (lat, lon) or (city, state, country)")

        r = await client.get(url, params=params)
        r.raise_for_status()
        return r.json()
