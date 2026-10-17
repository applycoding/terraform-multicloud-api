module "network" {
  source = "../../modules/gcp/network"

  name                    = var.name
  project_id              = var.project_id
  region                  = var.region
  subnet_cidr             = var.subnet_cidr
  private_service_address = var.private_service_address
}

module "cloud_sql" {
  source = "../../modules/gcp/cloud_sql"

  name                       = var.name
  project_id                 = var.project_id
  region                     = var.region
  network_id                 = module.network.network_id
  private_service_connection = module.network.private_service_connection
  tier                       = var.database_tier
  labels                     = var.labels
}

module "secret_manager" {
  source = "../../modules/gcp/secret_manager"

  project_id = var.project_id
  region     = var.region
  secret_id  = "${var.name}-database-url"
  labels     = var.labels
}

module "cloud_run" {
  source = "../../modules/gcp/cloud_run"

  name               = var.name
  project_id         = var.project_id
  region             = var.region
  environment        = var.environment
  image              = var.image
  network_self_link  = module.network.network_self_link
  subnet_self_link   = module.network.subnet_self_link
  database_secret_id = module.secret_manager.secret_id
  min_instance_count = var.min_instance_count
  max_instance_count = var.max_instance_count
  invoker_members    = var.invoker_members
  labels             = var.labels
}

resource "google_sql_user" "run" {
  project  = var.project_id
  name     = trimsuffix(module.cloud_run.service_account_email, ".gserviceaccount.com")
  instance = module.cloud_sql.instance_name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}
