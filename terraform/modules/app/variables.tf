variable "namespace" {
  type    = string
  default = ""
}

variable "secret_name" {
  type    = string
  default = ""
}

variable "secret_data" {
  type    = any
  default = {}
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}
