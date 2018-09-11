resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "BarkTable"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "Username"
  range_key      = "Timestamp"

  # Enable DynamoDB Streams
  # https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Streams.html
  stream_enabled = true
  # I nformation that will be written to the stream whenever data in the table is modified
  # New and old images—both the new and the old images of the item.
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "Username"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "S"
  }

  tags {
    Name        = "dynamodb-table-barck-table"
  }
}
