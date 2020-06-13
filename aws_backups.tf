# A terraform configuration for AWS Backups

# variables + defaults
variable "aws_region" {
  type                     = string
}

variable "aws_profile" {
  type                     = string
}

provider "aws" {
  region                   = var.aws_region
  profile                  = var.aws_profile
}

variable "aws_bu_event_schedule" {
  type                     = string
  default                  = "cron(0 0 ? * 1 *)"
}

variable "aws_bu_delete_after_days" {
  type                     = number
  default                  = 14
}

variable "aws_bu_name" {
  type                     = string
  default                  = "backups_1"
}

variable "aws_bu_tag_key" {
  type                     = string
  default                  = "Backup"
}

variable "aws_bu_tag_value" {
  type                     = string
  default                  = "backups_1"
}

# AWS KMS (the encryption key)
resource "aws_kms_key" "backups_1_key" {
  description              = "${var.aws_bu_name}_key"
}

# AWS IAM (the role and policy attachment)
resource "aws_iam_role" "backups_1_role" {
  name                     = "${var.aws_bu_name}_role"
  assume_role_policy       = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "backups_1_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.backups_1_role.name
}

# AWS Backup (the vault, plan, and selection)
resource "aws_backup_vault" "backups_1_vault" {
  name                     = "${var.aws_bu_name}_vault"
  kms_key_arn              = aws_kms_key.backups_1_key.arn
}

resource "aws_backup_plan" "backups_1_plan" {
  name                     = "${var.aws_bu_name}_plan"
  depends_on               = [aws_backup_vault.backups_1_vault]
  rule {
    rule_name                = "${var.aws_bu_name}_rule"
    target_vault_name        = "${var.aws_bu_name}_vault"
    schedule                 = var.aws_bu_event_schedule
    lifecycle {
      delete_after             = var.aws_bu_delete_after_days
    }
  }
}

resource "aws_backup_selection" "backups_1_selection" {
  name                     = "${var.aws_bu_name}_selection"
  iam_role_arn             = aws_iam_role.backups_1_role.arn
  plan_id                  = aws_backup_plan.backups_1_plan.id

  selection_tag {
    type                     = "STRINGEQUALS"
    key                      = var.aws_bu_tag_key
    value                    = var.aws_bu_tag_value
  }
}
