resource "aws_vpc" "default_vpc" {
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = var.vpc_cidr_block

  tags = {
    Name = "Sample-VPC"
  }
}

resource "aws_subnet" "public-subnet-a" {
  vpc_id            = aws_vpc.default_vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = "eu-west-3a"

  tags = {
    Name = "public subnet A"
  }
}

resource "aws_subnet" "public-subnet-b" {
  vpc_id            = aws_vpc.default_vpc.id
  cidr_block        = var.public_subnet_cidr_2
  availability_zone = "eu-west-3a"

  tags = {
    Name = "public subnet B"
  }
}

resource "aws_subnet" "private-subnet-a" {
  vpc_id            = aws_vpc.default_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "eu-west-3b"

  tags = {
    Name = "private subnet A"
  }
}

resource "aws_subnet" "private-subnet-b" {
  vpc_id            = aws_vpc.default_vpc.id
  cidr_block        = var.private_subnet_cidr_2
  availability_zone = "eu-west-3b"

  tags = {
    Name = "private subnet B"
  }
}

resource "aws_nat_gateway" "public_nat_gateway_a" {
  subnet_id     = aws_subnet.public-subnet-a.id
  allocation_id = aws_eip.nat_a.id

  tags = {
    Name = "public nat gtw A"
  }
}

resource "aws_nat_gateway" "public_nat_gateway_b" {
  subnet_id     = aws_subnet.public-subnet-b.id
  allocation_id = aws_eip.nat_b.id

  tags = {
    Name = "public nat gtw B"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default_vpc.id

  route {
    gateway_id = aws_internet_gateway.default_internet_gateway.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "rt-public"
  }
}

resource "aws_route_table_association" "route_table_association_a" {
  subnet_id      = aws_subnet.public-subnet-a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "route_table_association_b" {
  subnet_id      = aws_subnet.public-subnet-b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.default_vpc.id

  route {
    nat_gateway_id = aws_nat_gateway.public_nat_gateway_a.id
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "rt-private-a"
  }
}

resource "aws_route_table_association" "route_table_association_c" {
  subnet_id      = aws_subnet.private-subnet-a.id
  route_table_id = aws_route_table.private_a.id
}


resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.default_vpc.id

  route {
    nat_gateway_id = aws_nat_gateway.public_nat_gateway_b.id
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "rt-private-b"
  }
}


resource "aws_route_table_association" "route_table_association_d" {
  subnet_id      = aws_subnet.private-subnet-b.id
  route_table_id = aws_route_table.private_b.id
}

resource "aws_network_acl" "public_network_acl_a" {
  vpc_id = aws_vpc.default_vpc.id

  subnet_ids = [
    aws_subnet.public-subnet-a.id,
  ]

  ingress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    rule_no    = 100
    action     = "allow"
  }

  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    rule_no    = 200
    action     = "allow"
  }
  tags = {
    Name = "public net ACL A"
  }
}

resource "aws_network_acl" "public_network_acl_b" {
  vpc_id = aws_vpc.default_vpc.id

  subnet_ids = [
    aws_subnet.public-subnet-b.id,
  ]

  ingress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    rule_no    = 100
    action     = "allow"
  }

  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
    rule_no    = 200
    action     = "allow"
  }

  tags = {
    Name = "public net ACL B"
  }
}

resource "aws_internet_gateway" "default_internet_gateway" {
  vpc_id = aws_vpc.default_vpc.id
}



resource "aws_security_group" "private-sg-a" {
  vpc_id = aws_vpc.default_vpc.id
  tags = {
    Name = "private SG A"
  }
}

resource "aws_eip" "nat_a" {

  tags = {
    Name = "EIP NAT A"
  }
}

resource "aws_eip" "nat_b" {

  tags = {
    Name = "EIP NAT B"
  }
}


resource "aws_kinesis_stream" "kinesis_stream_1" {
  tags        = merge(var.tags, {})
  shard_count = 1
  name        = var.kinesis_data_stream_name
}


resource "aws_iam_role" "firehose_role" {
  name               = var.firehose_iam_role
  tags               = merge(var.tags, {})
  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Effect": "Allow",
          "Principal": {
            "Service": "firehose.amazonaws.com"
          }
        }
      ]
    }
  EOF
}

resource "aws_iam_policy" "kinesis_put_record_policy" {
  name        = var.kinesis_put_record_policy_name
  description = "Allow put records to Kinesis Data Stream"

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ],
        "Effect": "Allow",
        "Resource": "${aws_kinesis_stream.kinesis_stream_1.arn}"
      }
    ]
  }
  EOF
}


resource "aws_iam_policy_attachment" "kinesis_put_record_policy_attachment" {
  name       = "kinesis_put_record_policy_attachment"
  policy_arn = aws_iam_policy.kinesis_put_record_policy.arn
  roles      = [aws_iam_role.lambda_role.id]
}

resource "aws_cloudwatch_log_group" "firehose_log_group" {
  name = var.firehoselog_group
}

resource "aws_kinesis_firehose_delivery_stream" "kinesis_kinesis_firehose_delivery_stream_1" {
  tags        = merge(var.tags, {})
  name        = var.delivery_stream_name
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.kinesis_stream_1.arn
    role_arn           = aws_iam_role.firehose_role.arn

  }

  extended_s3_configuration {
    role_arn        = aws_iam_role.firehose_role.arn
    bucket_arn      = aws_s3_bucket.firehose_destination_bucket.arn
    buffer_size     = 1
    buffer_interval = 60

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose_log_group.name
      log_stream_name = "S3Delivery"
    }

  }
}

resource "aws_s3_bucket" "firehose_destination_bucket" {
  tags   = merge(var.tags, {})
  bucket = var.destination_bucket
}


resource "aws_s3_bucket_server_side_encryption_configuration" "firehose_destination_bucket" {
  bucket = aws_s3_bucket.firehose_destination_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}



resource "aws_lambda_function" "lambda_function_1" {
  tags          = merge(var.tags, {})
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  function_name = var.lambda_function_name
  filename      = "lambda_function.zip"
  publish       = true
  timeout       = 900
  tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      KINESIS_FIREHOSE_STREAM_NAME = aws_kinesis_stream.kinesis_stream_1.name
    }
  }
}


resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda_policy"
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ],
        "Effect": "Allow",
        "Resource": "${aws_kinesis_stream.kinesis_stream_1.arn}"
      },
      {
        "Action": [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ],
        "Effect": "Allow",
        "Resource": "${aws_kinesis_firehose_delivery_stream.kinesis_kinesis_firehose_delivery_stream_1.arn}"
      }
    ]
  }
  EOF
}


resource "aws_iam_role" "lambda_role" {
  tags               = merge(var.tags, {})
  name               = var.lambda_role_name
  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Effect": "Allow",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          }
        }
      ]
    }
  EOF
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda_policy_attachment"
  policy_arn = aws_iam_policy.lambda_policy.arn
  roles      = [aws_iam_role.lambda_role.id]
}


resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_kinesis_stream_consumer" "kinesis_stream_consumer_8" {
  stream_arn = aws_kinesis_stream.kinesis_stream_1.arn
  name       = "Kinesis_Stream_consumer"
}


resource "aws_iam_policy" "firehose_policy" {
  name        = "firehose_policy"
  description = "Kinesis Firehose policy for access to S3 and Kinesis Data Stream"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.firehose_destination_bucket.arn,
          "${aws_s3_bucket.firehose_destination_bucket.arn}/*"
        ]
      },
      {
        Action = [
          "lambda:InvokeFunction",
        ]
        Effect   = "Allow"
        Resource = aws_lambda_function.lambda_function_1.arn
      },
      {
        Action = [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords"
        ]
        Effect   = "Allow"
        Resource = aws_kinesis_stream.kinesis_stream_1.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_policy_attachment" {
  policy_arn = aws_iam_policy.firehose_policy.arn
  role       = aws_iam_role.firehose_role.name
}

