data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "queue_key" {
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
    sid    = "AllowSqs"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sqs.amazonaws.com"]
    }

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid    = "AllowS3Events"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_kms_key" "queue" {
  description             = "CMK for ${var.name} log notification queue."
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.queue_key.json
  tags                    = merge(var.tags, { Name = "${var.name}-alb-logs" })
}

resource "aws_kms_alias" "queue" {
  name          = "alias/${var.name}-alb-logs"
  target_key_id = aws_kms_key.queue.key_id
}

resource "aws_sqs_queue" "events" {
  name                              = "${var.name}-alb-log-events"
  kms_master_key_id                 = aws_kms_key.queue.arn
  kms_data_key_reuse_period_seconds = 300
  message_retention_seconds         = 86400
  tags                              = merge(var.tags, { Name = "${var.name}-alb-log-events" })
}

data "aws_iam_policy_document" "events" {
  statement {
    sid    = "AllowS3Event"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.events.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.alb.arn, aws_s3_bucket.access.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_sqs_queue_policy" "events" {
  queue_url = aws_sqs_queue.events.id
  policy    = data.aws_iam_policy_document.events.json
}

resource "aws_s3_bucket" "alb" {
  #checkov:skip=CKV_AWS_144:Single-region demo. Add cross-region replication when a second region is part of the design.
  #checkov:skip=CKV_AWS_145:ALB access logs can be delivered only to SSE-S3 buckets. AWS rejects a KMS key for this bucket.
  bucket        = var.alb_logs_bucket_name
  force_destroy = true
  tags          = merge(var.tags, { Name = var.alb_logs_bucket_name })
}

resource "aws_s3_bucket" "access" {
  #checkov:skip=CKV_AWS_18:This bucket is the access-log destination and does not log to itself.
  #checkov:skip=CKV_AWS_144:Single-region demo. Add cross-region replication when a second region is part of the design.
  #checkov:skip=CKV_AWS_145:S3 server access logs can be delivered only to SSE-S3 buckets. AWS rejects a KMS key for this bucket.
  bucket        = var.alb_logs_access_bucket_name
  force_destroy = true
  tags          = merge(var.tags, { Name = var.alb_logs_access_bucket_name })
}

resource "aws_s3_bucket_ownership_controls" "alb" {
  bucket = aws_s3_bucket.alb.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_ownership_controls" "access" {
  bucket = aws_s3_bucket.access.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "alb" {
  bucket                  = aws_s3_bucket.alb.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "access" {
  bucket                  = aws_s3_bucket.access.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "alb" {
  bucket = aws_s3_bucket.alb.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "access" {
  bucket = aws_s3_bucket.access.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb" {
  #checkov:skip=CKV_AWS_145:ALB access logs can be delivered only to SSE-S3 buckets. AWS rejects a KMS key for this bucket.
  bucket = aws_s3_bucket.alb.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access" {
  #checkov:skip=CKV_AWS_145:S3 server access logs can be delivered only to SSE-S3 buckets. AWS rejects a KMS key for this bucket.
  bucket = aws_s3_bucket.access.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb" {
  bucket = aws_s3_bucket.alb.id

  rule {
    id     = "expire-alb-logs"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.alb]
}

resource "aws_s3_bucket_lifecycle_configuration" "access" {
  bucket = aws_s3_bucket.access.id

  rule {
    id     = "expire-access-logs"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.access]
}

resource "aws_s3_bucket_logging" "alb" {
  bucket        = aws_s3_bucket.alb.id
  target_bucket = aws_s3_bucket.access.id
  target_prefix = "s3-access/"
}

data "aws_iam_policy_document" "alb" {
  #checkov:skip=CKV_AWS_109:The wildcard principal is a deny of non-TLS requests, not a grant
  #checkov:skip=CKV_AWS_111:The wildcard principal is a deny of non-TLS requests, not a grant
  #checkov:skip=CKV_AWS_356:The deny uses Resource * on this bucket only and does not grant access
  statement {
    sid    = "AllowAlbLogDelivery"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.alb.arn}/alb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
  }

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.alb.arn,
      "${aws_s3_bucket.alb.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "access" {
  #checkov:skip=CKV_AWS_109:The wildcard principal is a deny of non-TLS requests, not a grant
  #checkov:skip=CKV_AWS_111:The wildcard principal is a deny of non-TLS requests, not a grant
  #checkov:skip=CKV_AWS_356:The deny uses Resource * on this bucket only and does not grant access
  statement {
    sid    = "AllowAccessLogDelivery"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.access.arn}/s3-access/*"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.alb.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.access.arn,
      "${aws_s3_bucket.access.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "alb" {
  bucket = aws_s3_bucket.alb.id
  policy = data.aws_iam_policy_document.alb.json

  depends_on = [aws_s3_bucket_public_access_block.alb]
}

resource "aws_s3_bucket_policy" "access" {
  bucket = aws_s3_bucket.access.id
  policy = data.aws_iam_policy_document.access.json

  depends_on = [aws_s3_bucket_public_access_block.access]
}

resource "aws_s3_bucket_notification" "alb" {
  bucket = aws_s3_bucket.alb.id

  queue {
    queue_arn = aws_sqs_queue.events.arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_sqs_queue_policy.events]
}

resource "aws_s3_bucket_notification" "access" {
  bucket = aws_s3_bucket.access.id

  queue {
    queue_arn = aws_sqs_queue.events.arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_sqs_queue_policy.events]
}
