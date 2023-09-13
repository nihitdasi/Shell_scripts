#!/bin/bash

# Set your AWS region and the desired S3 bucket name
AWS_REGION="us-east-1"
BUCKET_NAME="nihit"

# Create the S3 bucket using the AWS CLI
aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"

# Check the exit code of the command to determine if the bucket was created successfully
if [ $? -ne 0 ]; then
    echo "Failed to create S3 bucket '$BUCKET_NAME'. Exiting..."
    exit 1
fi

# Get the current week number
CURRENT_WEEK=$(date +%U)

# Define the local directory where your "instances" folder is located
LOCAL_INSTANCES_DIR="/root/demo_files"

# List files in the "instances" directory
FILES=$(ls "$LOCAL_INSTANCES_DIR")

# Loop through the files
for FILE in $FILES; do
    # Get the week number of the file
    FILE_WEEK=$(date -r "$LOCAL_INSTANCES_DIR/$FILE" +%U)

    # Check if the file is from the current week
    if [ "$FILE_WEEK" -eq "$CURRENT_WEEK" ]; then
        echo "Keeping file '$FILE' in the local 'instances' folder for the current week."
    else
        # Move the file to S3 bucket
        aws s3 mv "$LOCAL_INSTANCES_DIR/$FILE" "s3://$BUCKET_NAME/"
        echo "Moved file '$FILE' to S3 bucket '$BUCKET_NAME'."
    fi
done
