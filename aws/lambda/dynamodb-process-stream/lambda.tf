# Create a role that can be assumed by lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Provides list and read access to DynamoDB streams and write permissions to CloudWatch logs
resource "aws_iam_role_policy_attachment" "iam_for_lambda" {
    role       = "${aws_iam_role.iam_for_lambda.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
}

# Create the lamda function
# https://www.terraform.io/docs/providers/aws/r/lambda_function.html
resource "aws_lambda_function" "test_lambda" {
  filename         = "src/deploy/ProcessDynamoDBStream.zip"
  function_name    = "ProcessDynamoDBStream"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "ProcessDynamoDBStream.lambda_handler"
  source_code_hash = "${base64sha256(file("src/deploy/ProcessDynamoDBStream.zip"))}"
  runtime          = "python2.7"
}

# This creates a mapping between the specified DynamoDB stream and the Lambda function,
# by associating the Lambda function (test_lambda) with an event source (the BarkTable stream).
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size        = 100
  event_source_arn  = "${aws_dynamodb_table.basic-dynamodb-table.stream_arn}"
  enabled           = true
  function_name     = "${aws_lambda_function.test_lambda.arn}"
  starting_position = "TRIM_HORIZON"
}
