variable "ec2_instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "CitroenRendezvousOrg"
}
variable "ec2_ami_id" {
  description = "Type of ami use for the EC2 instance"
  type        = string
  default     = "ami-60b6c60a"
}
variable "ec2_instance_type" {
  description = "Type of EC2 instance"
  type        = string
  default     = "t2.micro"
}
variable "ec2_availability_zone" {
  description = "Availability zone of EC2 instance"
  type        = string
  default     = "us-east-1"
}