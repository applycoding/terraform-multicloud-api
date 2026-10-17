provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "portfolio-api"
      Environment = var.environment
      ManagedBy   = "terraform"
      Repository  = "terraform-multicloud-api"
      Demo        = "true"
    }
  }
}

module "platform" {
  source = "../../../stacks/aws"

  name                        = "portfolio-${var.environment}"
  environment                 = var.environment
  vpc_cidr                    = var.vpc_cidr
  az_count                    = var.az_count
  single_nat_gateway          = var.single_nat_gateway
  certificate_arn             = var.certificate_arn
  container_image             = var.container_image
  desired_count               = var.desired_count
  task_cpu                    = var.task_cpu
  task_memory                 = var.task_memory
  database_instance_class     = var.database_instance_class
  rotation_lambda_arn         = var.rotation_lambda_arn
  alb_logs_bucket_name        = var.alb_logs_bucket_name
  alb_logs_access_bucket_name = var.alb_logs_access_bucket_name
}
