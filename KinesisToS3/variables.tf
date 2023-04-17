variable "public_subnet_cidr" {
  description = "The CIDR of the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_cidr_2" {
  description = "The CIDR of the public subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_cidr" {
  description = "The CIDR of the private subnet."
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_cidr_2" {
  description = "The CIDR of the private subnet."
  type        = string
  default     = "10.0.4.0/24"
}



variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(any)
  default = {
    archuuid = "66144f77-7e43-418d-b2bd-f2adcee6c59e"
    env      = "Development"
  }
}

variable "vpc_cidr_block" {
  description = "The CIDR of the main VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "kinesis_data_stream_name" {
  description = "The Name of the main Kinesis Data Stream."
  type        = string
  default     = "Kinesis"
}

variable "firehose_iam_role" {
  description = "The Name of the main firehose iam role."
  type        = string
  default     = "firehose_delivery_stream_role"
}

variable "kinesis_put_record_policy_name" {
  description = "The Name of the main firehose iam role."
  type        = string
  default     = "kinesis_put_record_policy"
}

variable "lambda_role_name" {
  description = "The Name of the main lambda iam role."
  type        = string
  default     = "lambda-to-kinesis-role"
}

variable "firehoselog_group" {
  description = "The Name of the main firehose iam role."
  type        = string
  default     = "/aws/kinesisfirehose/delivery-stream"
}

variable "delivery_stream_name" {
  description = "The Name of the firehose delivery stream"
  type        = string
  default     = "delivery_stream"
}

variable "destination_bucket" {
  description = "The Name of the s3 destination bucket"
  type        = string
  default     = "my-firehose-destination-bucket-bb"
}

variable "lambda_function_name" {
  type    = string
  default = "data_producer"
}