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
  name = "lambda_LambdaFunctionOverHttps"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [

    {
      "Action": [
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:UpdateItem"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
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
resource "aws_lambda_function" "test_lambda" {
  filename         = "src/deploy/LambdaFunctionOverHttps.zip"
  function_name    = "LambdaFunctionOverHttps"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "LambdaFunctionOverHttps.handler"
  source_code_hash = "${base64sha256(file("src/deploy/LambdaFunctionOverHttps.zip"))}"
  runtime          = "python2.7"
}

# grant Amazon API gateway service principal (apigateway.amazonaws.com) permissions to perform the lambda:InvokeFunction action
resource "aws_lambda_permission" "allow_nvgl_source" {
  statement_id  = "LambdaFunctionOverHttps"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.test_lambda.arn}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_deployment.DynamoDBOperationsDeployment.execution_arn}/POST/DynamoDBManager"
}
