terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "udacity-terraform-demo"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id  
  force_destroy = true
}

resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

data "archive_file" "lambda_udacity_demo" {
  type = "zip"
  source_file  = "greet_lambda.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_s3_object" "lambda_udacity_demo" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "lambda_function_payload.zip"
  source = data.archive_file.lambda_udacity_demo.output_path

  etag = filemd5(data.archive_file.lambda_udacity_demo.output_path)
}

resource "aws_lambda_function" "udacity_lambda" {
  function_name = "udacity_lambda"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_udacity_demo.key

  runtime = "python3.9"
  handler = "greet_lambda.lambda_handler"

  source_code_hash = data.archive_file.lambda_udacity_demo.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

   environment {
    variables = {
      greeting = "Hello"
    }
  }
}

resource "aws_cloudwatch_log_group" "udacity_demo" {
  name = "/aws/lambda/${aws_lambda_function.udacity_lambda.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}