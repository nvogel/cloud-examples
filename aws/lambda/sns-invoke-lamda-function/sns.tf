resource "aws_sns_topic" "user_updates" {
    name = "user-updates-topic"
}


resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = "${aws_sns_topic.user_updates.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.lambda.arn}"
}
