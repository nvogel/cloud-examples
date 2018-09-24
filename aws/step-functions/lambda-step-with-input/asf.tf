# Create a role that can be assumed by the amazon steps functions
resource "aws_iam_role" "iam_for_asf" {
  name = "iam_for_asf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Create a policy so the amazon step functions can call our lambda function
resource "aws_iam_policy" "asf_policies" {
  name = "lambda_asf"
  path = "/"
  description = "Allow Lamdba invocation"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction"
            ],
            "Resource": [
              "arn:aws:lambda:*:*:function:LambdaFunction"
            ]
        }
    ]
}
EOF
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "asf_attach" {
  role = "${aws_iam_role.iam_for_asf.name}"
  policy_arn = "${aws_iam_policy.asf_policies.arn}"
}


# Define the state machine
resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "my-state-machine"
  role_arn = "${aws_iam_role.iam_for_asf.arn}"

  definition = <<EOF
{
  "Comment": "A Hello World example of the Amazon States Language using an AWS Lambda Function",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.lambda.arn}",
      "End": true
    }
  }
}
EOF
}
