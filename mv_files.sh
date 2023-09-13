#!/bin/bash

# Set your AWS region and the desired S3 bucket name
AWS_REGION="us-east-2"
BUCKET_NAME="Bridgera"

# Create the S3 bucket using the AWS CLI
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"

# Check the exit code of the command to determine if the bucket was created successfully
if [ $? -ne 0 ]; then
    echo "Failed to create S3 bucket '$BUCKET_NAME'. Exiting..."
    exit 1
fi
