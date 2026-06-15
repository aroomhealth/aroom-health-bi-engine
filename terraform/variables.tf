variable "project_id" {
  type        = string
  description = "O ID do projeto do GCP"
  default     = "iron-rex-461220-g4"
}

variable "region" {
  type        = string
  description = "A regiao padrao dos recursos do GCP"
  default     = "us-central1"
}

variable "dataset_raw" {
  type        = string
  description = "Nome do dataset de dados brutos"
  default     = "database_aroom_health"
}

variable "dataset_curated" {
  type        = string
  description = "Nome do dataset de dados refinados"
  default     = "customer_intelligence"
}
