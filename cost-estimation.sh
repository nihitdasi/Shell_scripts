#!/bin/bash

# Instance details
INSTANCE_NAME="demo_instance"
PUBLIC_IP="18.116.45.231"
PRIVATE_IP="172.31.14.102"
INSTANCE_TYPE="t2.medium"
CPUS="1"

RAM_GB="1"
VOLUME_SIZE_GB="8"

# Pricing information 
VOLUME_COST_PER_GB_PER_MONTH=0.10  # amount in dollars.
INSTANCE_COST_PER_HOUR=0.0116       # amount in dollars.

# Calculate total cost
INSTANCE_COST_PER_MONTH=$(bc <<< "scale=2; $INSTANCE_COST_PER_HOUR * 24 * 30")

VOLUME_COST_PER_MONTH=$(bc <<< "scale=2; $VOLUME_SIZE_GB * $VOLUME_COST_PER_GB_PER_MONTH")

TOTAL_COST_PER_MONTH=$(bc <<< "scale=2; $INSTANCE_COST_PER_MONTH + $VOLUME_COST_PER_MONTH")

# Print the cost estimation
echo "Cost Estimation for $INSTANCE_NAME"
echo "----------------------------------"
echo "Instance Type: $INSTANCE_TYPE"
echo "CPUs: $CPUS"
echo "RAM: ${RAM_GB}GB"
echo "Volume Size: ${VOLUME_SIZE_GB}GB"
echo "Public IP: $PUBLIC_IP"
echo "Private IP: $PRIVATE_IP"
echo ""
echo "Estimated Costs:"
echo "Instance Cost per Hour: \$${INSTANCE_COST_PER_HOUR}"
echo "Volume Cost per Month: \$${VOLUME_COST_PER_MONTH}"
echo "Total Cost per Month: \$${TOTAL_COST_PER_MONTH}"
