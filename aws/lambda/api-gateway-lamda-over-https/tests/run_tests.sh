#!/usr/bin/env bash

API_ID=$(aws apigateway get-rest-apis --region us-west-2 --query 'items[?name==`DynamoDBOperations`].id'  --output text)

# Call the resource DynamoDBManager
curl -X POST -d "{\"operation\":\"create\",\"tableName\":\"LambdaFunctionOverHttps\",\"payload\":{\"Item\":{\"id\":\"$(date)\",\"name\":\"Bob\"}}}" \
    "https://${API_ID}.execute-api.us-west-2.amazonaws.com/prod/DynamoDBManager"

# List entries in the dynamotable
aws dynamodb scan --table-name LambdaFunctionOverHttps  --region us-west-2
