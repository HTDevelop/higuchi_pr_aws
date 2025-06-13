import boto3
import uuid
import time


class DynamoDB:
    def __init__(self):
        self.table_name = "higuchi-pr"
        self.dynamodb = boto3.client("dynamodb", region_name="ap-northeast-1")

    def put_support_msg(self, value: str) -> str:
        p_key = str(uuid.uuid4())
        expire_ts = int(time.time()) + 7 * 24 * 60 * 60 

        self.dynamodb.put_item(
            TableName=self.table_name,
            Item={
                "p_key": {"S": p_key},
                "sort_key": {"S": "support_msg"},
                "value": {"S": value},
                "expire_date": {"N": str(expire_ts)}
            }
        )
        return p_key

    def fetch_all_support_msg(self):
        return self.__query_items_by_sort_key("support_msg")

    def __query_items_by_sort_key(self, sort_key_value) -> list[str]:
        response = self.dynamodb.query(
            TableName=self.table_name,
            IndexName="sort-key-index",
            KeyConditionExpression="sort_key = :sk",
            ExpressionAttributeValues={":sk": {"S": sort_key_value}},
            ProjectionExpression="p_key, sort_key"
        )

        results = []
        for item in response.get("Items", []):
            p_key = item["p_key"]["S"]
            full_item = self.dynamodb.get_item(
                TableName=self.table_name,
                Key={
                    "p_key": {"S": p_key},
                    "sort_key": {"S": sort_key_value}
                }
            )
            value = full_item.get("Item", {}).get("value", {}).get("S", "")
            results.append(value)
        return results