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

# Enable logs and r/w on specifics buckets
resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy_create_thumbnail"
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
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::nvglsource/*",
        "arn:aws:s3:::nvglsourceresized/*"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

# Create the function
# https://www.terraform.io/docs/providers/aws/r/lambda_function.html
# The function can access to s3 buckets
resource "aws_lambda_function" "test_lambda" {
  filename         = "CreateThumbnail/deploy/CreateThumbnail.zip"
  function_name    = "CreateThumbnail"
  role             = "${aws_iam_role.iam_for_lambda.arn}"
  handler          = "CreateThumbnail.handler"
  source_code_hash = "${base64sha256(file("CreateThumbnail/deploy/CreateThumbnail.zip"))}"
  runtime          = "python2.7"
  memory_size      = "1024"
  timeout          = "10"
}

# grant Amazon S3 service principal (s3.amazonaws.com) permissions to perform the lambda:InvokeFunction action
# What service can invoke the lamda
resource "aws_lambda_permission" "allow_nvgl_source" {
  statement_id  = "AllowExecutionFromS3NvglSource"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.test_lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.nvglsource.arn}"
}

# Bucket notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.nvglsource.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.test_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}
