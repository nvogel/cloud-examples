variable "namespace" {
  type        = "string"
  default     = "nvgl"
  description = "namespace"
}

variable "stage" {
  type        = "string"
  default     = "test"
  description = "stage"
}

variable "name" {
  type        = "string"
  default     = "kubernetes"
  description = "name"
}

variable "private_zone" {
  type        = "string"
  default     = "internal.k8s"
  description = "Private zone"
}
