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