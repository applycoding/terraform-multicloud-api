module "vpc" {
  source = "../../modules/aws/vpc"

  name               = var.name
  cidr_block         = var.vpc_cidr
  availability_zones = var.availability_zones
  single_nat_gateway = var.single_nat_gateway
  tags               = var.tags
}

module "logging" {
  source = "../../modules/aws/logging"

  name           = var.name
  log_group_name = "/${var.name}/api"
  tags           = var.tags
}

module "secrets" {
  source = "../../modules/aws/secrets"

  name                = var.name
  secret_name         = "${var.name}/database-url"
  rotation_lambda_arn = var.rotation_lambda_arn
  tags                = var.tags
}

module "alb" {
  source = "../../modules/aws/alb"

  name                        = var.name
  vpc_id                      = module.vpc.vpc_id
  public_subnet_ids           = module.vpc.public_subnet_ids
  certificate_arn             = var.certificate_arn
  alb_logs_bucket_name        = var.alb_logs_bucket_name
  alb_logs_access_bucket_name = var.alb_logs_access_bucket_name
  tags                        = var.tags
}

module "ecs" {
  source = "../../modules/aws/ecs"

  name                  = var.name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  vpc_cidr              = module.vpc.vpc_cidr
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.alb.security_group_id
  target_group_arn      = module.alb.target_group_arn
  container_image       = var.container_image
  desired_count         = var.desired_count
  cpu                   = var.task_cpu
  memory                = var.task_memory
  log_group_name        = module.logging.log_group_name
  log_kms_key_arn       = module.logging.kms_key_arn
  database_secret_arn   = module.secrets.secret_arn
  secrets_kms_key_arn   = module.secrets.kms_key_arn
  tags                  = var.tags
}

module "rds" {
  source = "../../modules/aws/rds"

  name                  = var.name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  app_security_group_id = module.ecs.security_group_id
  instance_class        = var.database_instance_class
  tags                  = var.tags
}
