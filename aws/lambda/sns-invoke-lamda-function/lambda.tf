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

# The lamda function can use
resource "aws_iam_policy" "lambda_policies" {
  name = "lambda_LambdaFunction"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_policies.arn}"
}

# Create the lamda function
# https://www.terraform.io/docs/providers/aws/r/lambda_function.html
resource "aws_lambda_function" "lambda" {
  filename         = "src/deploy/LambdaFunction.zip"
  function_name    = "LambdaFunction"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "LambdaFunction.handler"
  source_code_hash = "${base64sha256(file("src/deploy/LambdaFunction.zip"))}"
  runtime          = "python2.7"
}

# Allow sns to call our lambda function
resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.user_updates.arn}"
}
