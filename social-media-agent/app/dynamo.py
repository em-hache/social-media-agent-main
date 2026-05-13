# social-media-agent/app/dynamo.py
import aioboto3
from .config import settings

session = aioboto3.Session()

def get_dynamo_client():
    return session.client(
        "dynamodb",
        endpoint_url=settings.dynamodb_endpoint,
        region_name=settings.aws_default_region,
        aws_access_key_id=settings.aws_access_key_id,
        aws_secret_access_key=settings.aws_secret_access_key,
    )
