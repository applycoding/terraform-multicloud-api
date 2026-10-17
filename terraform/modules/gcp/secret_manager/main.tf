data "google_project" "current" {
  project_id = var.project_id
}

resource "google_kms_key_ring" "secrets" {
  project  = var.project_id
  name     = "${var.secret_id}-ring"
  location = var.region
}

resource "google_kms_crypto_key" "secrets" {
  name            = "app"
  key_ring        = google_kms_key_ring.secrets.id
  rotation_period = "7776000s"
  purpose         = "ENCRYPT_DECRYPT"

  labels = var.labels
}

resource "google_kms_crypto_key_iam_member" "secrets" {
  crypto_key_id = google_kms_crypto_key.secrets.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-secretmanager.iam.gserviceaccount.com"
}

resource "google_pubsub_topic" "rotation" {
  project = var.project_id
  name    = "${var.secret_id}-rotation"
  labels  = var.labels
}

resource "google_secret_manager_secret" "app" {
  project   = var.project_id
  secret_id = var.secret_id
  labels    = var.labels

  replication {
    user_managed {
      replicas {
        location = var.region

        customer_managed_encryption {
          kms_key_name = google_kms_crypto_key.secrets.id
        }
      }
    }
  }

  topics {
    name = google_pubsub_topic.rotation.id
  }

  rotation {
    rotation_period    = "2592000s"
    next_rotation_time = var.next_rotation_time
  }

  depends_on = [google_kms_crypto_key_iam_member.secrets]
}
