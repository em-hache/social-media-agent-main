# social-media-agent/app/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    env: str = "production"
    database_url: str = "postgresql+asyncpg://admin:secret@main-database:5432/appdb"
    dynamodb_endpoint: str = "http://dynamodb:8000"
    aws_access_key_id: str = "local"
    aws_secret_access_key: str = "local"
    aws_default_region: str = "us-east-1"

    class Config:
        env_file = ".env"

settings = Settings()
