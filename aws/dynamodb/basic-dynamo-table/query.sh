



# Query the Thread table for a particular ForumName (partition key).
# All of the items with that ForumName value will be read by the query, because the sort key (Subject) is not included in KeyConditionExpression.
aws dynamodb query --table-name Thread --key-condition-expression "ForumName = :name" --expression-attribute-values  '{":name":{"S":"Amazon DynamoDB"}}'



# Query the Thread table for a particular ForumName (partition key), but this time return only the items with a given Subject (sort key).
aws dynamodb query --table-name Thread --key-condition-expression "ForumName = :name and Subject = :sub" --expression-attribute-values  file://values/query-2.json
