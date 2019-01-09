# Define the aws provider
provider "aws" {
  region = "eu-west-1"
}

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

# Provides receive message, delete message, and read attribute access to SQS queues, and write permissions to CloudWatch logs
resource "aws_iam_role_policy_attachment" "iam_for_lambda" {
    role       = "${aws_iam_role.iam_for_lambda.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

# Create the lamda function
# https://www.terraform.io/docs/providers/aws/r/lambda_function.html
resource "aws_lambda_function" "LambdaFunction" {
  filename         = "src/deploy/LambdaFunction.zip"
  function_name    = "LambdaFunction"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "LambdaFunction.handler"
  source_code_hash = "${base64sha256(file("src/deploy/LambdaFunction.zip"))}"
  runtime          = "python3.7"
}


# Define a sqs queue
resource "aws_sqs_queue" "queue" {
  name                      = "lamba-sqs"

  tags = {
    Environment = "lamda-sqs"
  }
}

# Msp the the queue to the lambda event
resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = "${aws_sqs_queue.queue.arn}"
  function_name    = "${aws_lambda_function.LambdaFunction.arn}"
}



