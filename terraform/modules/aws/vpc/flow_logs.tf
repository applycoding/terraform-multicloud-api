data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "logs_key" {
  #checkov:skip=CKV_AWS_109:Account root must retain key administration so the CMK cannot be locked out
  #checkov:skip=CKV_AWS_111:The root statement is key administration, not a workload write path
  #checkov:skip=CKV_AWS_356:KMS key policies require Resource * because keys have no ARN-level resource restriction
  statement {
    sid    = "EnableRootPermissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo",
      "kms:GenerateDataKey",
      "kms:DescribeKey",
    ]
    resources = ["*"]

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"]
    }
  }
}

resource "aws_kms_key" "flow" {
  description             = "CMK for ${var.name} VPC flow logs."
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.logs_key.json
  tags                    = merge(var.tags, { Name = "${var.name}-vpc-flow" })
}

resource "aws_kms_alias" "flow" {
  name          = "alias/${var.name}-vpc-flow"
  target_key_id = aws_kms_key.flow.key_id
}

resource "aws_cloudwatch_log_group" "flow" {
  name              = "/${var.name}/vpc-flow"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.flow.arn
  tags              = merge(var.tags, { Name = "/${var.name}/vpc-flow" })
}

data "aws_iam_policy_document" "flow_assume" {
  statement {
    sid     = "AllowVpcFlowLogs"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flow" {
  name               = "${var.name}-vpc-flow"
  assume_role_policy = data.aws_iam_policy_document.flow_assume.json
  tags               = merge(var.tags, { Name = "${var.name}-vpc-flow" })
}

data "aws_iam_policy_document" "flow" {
  statement {
    sid    = "WriteFlowLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = ["${aws_cloudwatch_log_group.flow.arn}:*"]
  }

  statement {
    sid    = "UseFlowLogKey"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey",
    ]
    resources = [aws_kms_key.flow.arn]
  }
}

resource "aws_iam_role_policy" "flow" {
  name   = "flow-logs"
  role   = aws_iam_role.flow.id
  policy = data.aws_iam_policy_document.flow.json
}

resource "aws_flow_log" "this" {
  vpc_id                   = aws_vpc.this.id
  traffic_type             = "ALL"
  iam_role_arn             = aws_iam_role.flow.arn
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.flow.arn
  max_aggregation_interval = 60
  tags                     = merge(var.tags, { Name = "${var.name}-flow" })
}
