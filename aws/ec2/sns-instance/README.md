# Description

An ec2 instance witch a role allowing  to send an event to a sns topic via a cloud watch custom event.

# Test

event.json file :

```
[
        {
            "Source": "com.ami.builder",
            "DetailType": "AmiBuilder",
            "Detail": "{ \"AmiStatus\" : [\"Created\"] }",
            "Resources": [ "<<AMI-ID>>" ]
        }
]
```

From the ec2 instances :

```
aws events put-events --entries file://event.json --region eu-west-1
```
