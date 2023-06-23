provider "aws" {
  region = "us-west-1a" 
}

resource "aws_s3_bucket" "sample_bucket" {
  bucket = "sample-bucket-name"  
  acl    = "private"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "sample_lambda" {
  function_name = "sample-lambda" 
  handler       = "index.handler"
  runtime       = "nodejs12.x"  

  role = aws_iam_role.lambda_role.arn

  filename      = "path/to/lambda/code.zip"
  source_code_hash = filebase64sha256("path/to/lambda/code.zip")

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.sample_bucket.id
    }
  }
}
