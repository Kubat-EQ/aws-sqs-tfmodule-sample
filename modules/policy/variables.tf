variable "kms_key_arns" {
  type = list(string)
}

variable "sqs_queue_arns" {
  type = list(string)
}

variable "user_name" {
  type    = string
  default = null
}

variable "role_id" {
  type    = string
  default = null
}

variable "bucket_names" {
  type    = list(string)
  default = []
}
