resource "aws_dynamodb_table" "higuchi_pr" {
  name           = "higuchi-pr"
  billing_mode   = "PAY_PER_REQUEST"  # オンデマンド課金
  hash_key       = "p_key"
  range_key      = "sort_key"

  attribute {
    name = "p_key"
    type = "S"
  }

  attribute {
    name = "sort_key"
    type = "S"
  }

  ttl {
    attribute_name = "expire_date"
    enabled        = true
  }

  global_secondary_index {
    name            = "sort-key-index"
    hash_key        = "sort_key"
    projection_type = "ALL"  # 必要な属性だけにする場合は KEYS_ONLY or INCLUDE を使う
  }
}
