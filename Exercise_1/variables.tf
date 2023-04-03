variable "t2_instance_name" {
  description = "Value of the Name tag for T2 EC2 instance"
  type        = string
  default     = "Udacity T2"
}

variable "m4_instance_name" {
  description = "Value of the Name tag for M4 EC2 instance"
  type        = string
  default     = "Udacity M4"
}

variable "vpc_id" {
    description = "VPC ID"
    type = string
    default = "value"
}

variable "subnet_id" {
    description = "Subnet ID"
    type = string
    default = "value"
}