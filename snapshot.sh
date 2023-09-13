#!/bin/bash

# AWS CLI profile name (if using profiles)
# AWS_PROFILE="your-profile-name"

# EC2 Instance ID (replace with your instance ID)
INSTANCE_ID="i-04cbe853d62273689"

# EBS Volume Configuration
VOLUME_SIZE=10   # Volume size in GB
VOLUME_TYPE="gp2"  # Volume type (e.g., gp2, io1)
VOLUME_NAME="MyDataVolume"  # Name for the EBS volume

# Function to create an EBS volume
create_volume() {
  local size="$1"
  local volume_type="$2"
  local name="$3"

  aws ec2 create-volume --availability-zone us-east-1a --size "$size" --volume-type "$volume_type" --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=$name}]"
}

# Function to attach an EBS volume to an EC2 instance
attach_volume() {
  local volume_id="$1"
  aws ec2 attach-volume --volume-id "$volume_id" --instance-id "$INSTANCE_ID" --device /dev/xvdf
}

# Function to create an EBS snapshot
create_snapshot() {
  local volume_id="$1"
  local description="$2"
  aws ec2 create-snapshot --volume-id "$volume_id" --description "$description"
}

# Function to delete an EBS snapshot
delete_snapshot() {
  local snapshot_id="$1"
  aws ec2 delete-snapshot --snapshot-id "$snapshot_id"
}

# Main script
echo "Creating an EBS volume..."
volume_result=$(create_volume "$VOLUME_SIZE" "$VOLUME_TYPE" "$VOLUME_NAME")
volume_id=$(echo "$volume_result" | jq -r '.VolumeId')

echo "Attaching the EBS volume to the EC2 instance..."
attach_volume "$volume_id"

snapshot_description="$VOLUME_NAME-$(date +%Y-%m-%d)"
echo "Creating a snapshot of the EBS volume..."
snapshot_result=$(create_snapshot "$volume_id" "$snapshot_description")
snapshot_id=$(echo "$snapshot_result" | jq -r '.SnapshotId')

echo "Snapshot ID: $snapshot_id"
echo "Snapshot Description: $snapshot_description"

# You can add more operations here, such as listing or deleting snapshots.
