from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any


class Pollutant(BaseModel):
    parameter: str
    value: float
    unit: str


class AirQuality(BaseModel):
    source: str = "OpenAQ"
    location: Optional[str] = None
    coordinates: Optional[Dict[str, float]] = None
    pollutants: List[Pollutant] = Field(default_factory=list)


class Weather(BaseModel):
    source: str = "OpenWeatherMap"
    temperature: Optional[float] = None
    humidity: Optional[int] = None
    description: Optional[str] = None
    icon: Optional[str] = None


class MetricsResponse(BaseModel):
    city: Optional[str] = None
    country: Optional[str] = None
    weather: Weather
    air_quality: AirQuality
