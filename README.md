# Reference
Deploys the AWS Backups service on schedule for resources with particular tags, using Terraform.

## Notes
- Includes required IAM role/policy for Lambda function.
- Includes an AWS-managed KMS key for vaulted objects
- Default tag:Backup:backup_1 (in .tf) for objects to be backed up.
- Default schedule/retention (in .tf) is 00:00 GMT on Sunday with 14 day retention.

## Deploy
```
# begin terraform
terraform init
terraform apply

# answer terraform variable(s)
var.aws_profile
  Enter a value: default

var.aws_region
  Enter a value: us-east-2

# confirm terraform action(s)
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```
