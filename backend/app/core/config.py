from functools import lru_cache

from pydantic import Field, computed_field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    app_name: str = "backend"
    app_version: str = "0.1.0"
    debug: bool = False

    host: str = "0.0.0.0"
    port: int = 8000

    jwt_secret_key: str = Field(
        default="CHANGE_ME_IN_PRODUCTION_must_be_at_least_32_characters_long",
        min_length=32,
    )
    jwt_algorithm: str = "HS256"
    jwt_access_token_expire_minutes: int = 30

    database_url: str = "sqlite+aiosqlite:///./app.db"

    cors_origins: list[str] = Field(default_factory=lambda: ["http://localhost:5173"])

    @computed_field
    @property
    def api_prefix(self) -> str:
        return "/api/v1"


@lru_cache
def get_settings() -> Settings:
    return Settings()
