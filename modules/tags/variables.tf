# modules/tags/tags.tf

variable "owner" {
  type    = string
  default = "andrei.rusnac"
}
variable "discipline" {
  type = string
  default = "AM"
}
variable "purpose" {
  type = string
  default = "Internship"
}
variable "project" {
  type = string
  default = "aws-lab1"
}
variable "nickname" {
  type    = string
  default = "Andriesh"
}
variable "deploy" {
  type    = string
  default = "Terraform"
}