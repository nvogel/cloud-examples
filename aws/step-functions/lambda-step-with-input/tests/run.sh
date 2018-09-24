#!/usr/bin/env bash

ARN=$(aws stepfunctions list-state-machines --region us-west-2 --query 'stateMachines[?name==`my-state-machine`]'.stateMachineArn --output text)
aws stepfunctions start-execution --state-machine-arn "$ARN" --region us-west-2 --input "{\"first_name\" : \"test\"}"
