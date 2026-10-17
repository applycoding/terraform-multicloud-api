data "google_project" "current" {
  project_id = var.project_id
}

resource "google_kms_key_ring" "sql" {
  project  = var.project_id
  name     = "${var.name}-sql"
  location = var.region
}

resource "google_kms_crypto_key" "sql" {
  name            = "database"
  key_ring        = google_kms_key_ring.sql.id
  rotation_period = "7776000s"
  purpose         = "ENCRYPT_DECRYPT"

  labels = var.labels

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key_iam_member" "sql" {
  crypto_key_id = google_kms_crypto_key.sql.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-cloud-sql.iam.gserviceaccount.com"
}

resource "google_sql_database_instance" "this" {
  project             = var.project_id
  name                = "${var.name}-pg"
  region              = var.region
  database_version    = "POSTGRES_18"
  encryption_key_name = google_kms_crypto_key.sql.id
  deletion_protection = true

  settings {
    tier                  = var.tier
    edition               = "ENTERPRISE"
    availability_type     = "REGIONAL"
    disk_type             = "PD_SSD"
    disk_size             = 20
    disk_autoresize       = true
    disk_autoresize_limit = 100
    user_labels           = var.labels

    deletion_protection_enabled = true

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_id
      ssl_mode                                      = "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      start_time                     = "03:00"
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = 14
        retention_unit   = "COUNT"
      }
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    maintenance_window {
      day          = 7
      hour         = 4
      update_track = "stable"
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }
    database_flags {
      name  = "log_connections"
      value = "on"
    }
    database_flags {
      name  = "log_disconnections"
      value = "on"
    }
    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }
    database_flags {
      name  = "log_min_messages"
      value = "warning"
    }
    database_flags {
      name  = "log_temp_files"
      value = "0"
    }
    database_flags {
      name  = "log_min_duration_statement"
      value = "-1"
    }
    database_flags {
      name  = "log_hostname"
      value = "on"
    }
    database_flags {
      name  = "log_min_error_statement"
      value = "error"
    }
    database_flags {
      name  = "cloudsql.enable_pgaudit"
      value = "on"
    }
    database_flags {
      name  = "pgaudit.log"
      value = "all"
    }
    database_flags {
      name  = "log_statement"
      value = "ddl"
    }
    database_flags {
      name  = "log_duration"
      value = "on"
    }
    database_flags {
      name  = "log_executor_stats"
      value = "off"
    }
    database_flags {
      name  = "log_parser_stats"
      value = "off"
    }
    database_flags {
      name  = "log_planner_stats"
      value = "off"
    }
    database_flags {
      name  = "log_statement_stats"
      value = "off"
    }
    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  }

  depends_on = [google_kms_crypto_key_iam_member.sql]

  lifecycle {
    precondition {
      condition     = length(var.private_service_connection) > 0
      error_message = "Create the service networking connection before Cloud SQL."
    }
  }
}

resource "google_sql_database" "app" {
  project  = var.project_id
  name     = var.database_name
  instance = google_sql_database_instance.this.name
}
