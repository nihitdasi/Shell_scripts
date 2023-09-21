#!/bin/bash

# Define the name of your Excel file
excel_file="aws_costs.xlsx"

# Retrieve information about volumes
volumes_info=$(aws ec2 describe-volumes --query 'Volumes[*].[VolumeId,Size,State]' --output text)

# Initialize variables to count running and stopped instances
running_instances=0
stopped_instances=0

# Create or clear the Excel file
echo -e "Volume ID\tSize (GiB)\tVolume State\tInstance ID\tInstance State\tInstance Cost" > "$excel_file"
# Loop through volumes and instances
while read -r volume; do
    volume_id=$(echo "$volume" | cut -f1)
    volume_size=$(echo "$volume" | cut -f2)
    volume_state=$(echo "$volume" | cut -f3)

    # Check if there are instances attached to the volume
    attached_instances=$(aws ec2 describe-instances --filters "Name=block-device-mapping.volume-id,Values=$volume_id" --query 'Reservations[*].Instances[*].InstanceId' --output text)
    for instance_id in $attached_instances; do
        instance_info=$(aws ec2 describe-instances --instance-ids "$instance_id" --query 'Reservations[*].Instances[*].[State.Name,InstanceType]' --output text)
        instance_state=$(echo "$instance_info" | cut -f1)
        instance_type=$(echo "$instance_info" | cut -f2)
        
        # Calculate the cost based on instance type
        if [ "$instance_state" = "running" ]; then
            if [ "$instance_type" = "t2.micro" ]; then
                instance_cost=$(bc <<< "$volume_size * 30 * 0.0116")  # Calculate monthly cost for running t2.micro instances
            elif [ "$instance_type" = "t2.medium" ]; then
                instance_cost=$(bc <<< "$volume_size * 30 * 0.0464")  # Calculate monthly cost for running t2.medium instances
            else
                instance_cost="N/A"
            fi
            ((running_instances++))
        else
            instance_cost="N/A"
            ((stopped_instances++))
        fi

        # Print information to the Excel file
        echo -e "$volume_id\t$volume_size\t$volume_state\t$instance_id\t$instance_state\t$instance_cost" >> "$excel_file"
    done
done <<< "$volumes_info"

# Print the total number of running and stopped instances
echo "Total Running Instances: $running_instances"
echo "Total Stopped Instances: $stopped_instances"

# Notify the user about the Excel file
echo "Excel file '$excel_file' has been generated with the requested information."
