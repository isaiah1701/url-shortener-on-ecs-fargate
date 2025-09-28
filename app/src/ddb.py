import os, uuid, boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])

def put_mapping(url: str) -> str:
    slug = uuid.uuid4().hex[:8]
    table.put_item(Item={"slug": slug, "url": url})
    return slug

def get_mapping(slug: str):
    resp = table.get_item(Key={"slug": slug})
    return resp.get("Item")