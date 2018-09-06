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

# Give access to s3 in a policy
data "aws_iam_policy_document" "s3-access" {
    statement {
        actions = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:ListBucket",
        ]
        resources = [
            "arn:aws:s3:::*",
        ]
    }
}

resource "aws_iam_policy" "s3-access" {
    name = "s3-access"
    path = "/"
    policy = "${data.aws_iam_policy_document.s3-access.json}"
}

# Associate the policy to the role
resource "aws_iam_role_policy_attachment" "s3-access" {
    role       = "${aws_iam_role.iam_for_lambda.name}"
    policy_arn = "${aws_iam_policy.s3-access.arn}"
}

# Enable logs
resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"
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

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
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
