variable "webport" {
default = 8080
type = number
}

variable "public_cidr" {
  type = any
}

variable "tags" {
  type = map(string)
}

variable "sshport" {
  type = number
}

variable "instance_type" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "max_size" {
  type = number
}
variable "min_size" {
  type = number
}
