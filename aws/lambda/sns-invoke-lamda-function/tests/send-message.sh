#!/usr/bin/env bash

export AWS_DEFAULT_REGION=us-west-2

TOPIC=$(aws sns list-topics --query 'Topics[0].TopicArn' --output=text)

echo "Send a message to ${TOPIC}"

aws sns publish --topic-arn "$TOPIC" --message "HELLO THIS IS A MESSAGE FOR SNS"
