#!/bin/bash

# Shell script to perform the following functions using aws cli
# 1) lists volumes id's attached to an EC2 instance.
# 2) provide attributes of an EBS volumes attached to EC2 intance.
# 3) provide the current status of an EBS volumes attached to an EC2 instance.

# Checks the attached ebs volumes to an ec2 instance.

function attached_volume() {
        INSTANCE_ID=$1
        echo " "
        $EC2_CLI describe-volumes --filters Name=attachment.instance-id,Values="$INSTANCE_ID" --output json | \
                               grep VolumeId | sed -e 's/"VolumeId"://g' -e 's/ //g' -e 's/,//g' -e 's/"//g'| sort| uniq
}
# Checks the attributes of ec2 volume attached to an ec2 instances.

function volume_features() {

        INSTANCE_ID=$1
        VOL_IDS=$(attached_volume "$INSTANCE_ID")

        for VOL_ID in ${VOL_IDS[@]};do
                VOLTYPE=$($EC2_CLI describe-volumes --volume-ids $VOL_ID --query 'Volumes[0].VolumeType' --output text)
                VOLIOPS=$($EC2_CLI describe-volumes --volume-ids $VOL_ID --query 'Volumes[0].Iops' --output text)
                VOLSIZEGB=$($EC2_CLI describe-volumes --volume-ids $VOL_ID --query 'Volumes[0].Size' --output text)
                KMSENCRPT=$($EC2_CLI describe-volumes --volume-ids $VOL_ID --query 'Volumes[].Encrypted' --output text)
                VOLAZ=$($EC2_CLI describe-volumes --volume-ids $VOL_ID --query 'Volumes[0].AvailabilityZone' --output text)
                VOLDEV=$($EC2_CLI describe-volumes --volume-ids $VOL_ID --query 'Volumes[0].Attechments[0].Device' --output text)
                
                echo " "
                echo -e "${Cya}Volume ID:  $VOL_ID \e[0m"
                echo "    Type    :       $VOLTYPE"
                echo "    IOPS    :       $VOLIOPS"
                echo "    Size    :       $VOLSIZEGB"
                echo "    Encrypt :       $KMSENCRPT"
                echo "    AZ      :       $VOLAZ"
                echo "    Device  :       $VOLDEV"
        done
}

# Checks the health status of ec2 volumes attached to an ec2 instance.

function volume_status() {

        INSTANCE_ID=$1
        VOL_IDS=$(attached_volume "$INSTANCE_ID")

        for VOL_ID in ${VOL_IDS[@]};do
                VOLSTATUS=$($EC2_CLI describe-volume-status --volume-id $VOL_ID --query \
                            'Volumestatuses[0].VolumeStatus.Details[0].STatus' --output text | sed -e 's/"//g')
                echo " "
                echo -e "${Cya}Volume ID:  $VOL_ID \e[0m"
                echo "    Status  :       $VOLSTATUS"
        done
}

# Script usage:

function usage() {
cat <<EOF

Usage:  bash awsvolstat.sh  [ --volume-list|--volume-attributes|--volume-status ]

Valid Options are:

    --volume-list        lists volume id's attached to an EC2 instance.
    --volume-attributes  provides attributes of an RBS volumes attavhed to an EC2 instance.
    --volume-status      provides the current status of EBS Volumes attached to an EC2 instance.

EOF

}

### Main Code ###

#Set colours(to make the script user friendly)

BRed='\e[1;31m'
BYel='\e[1;33m'
BCya='\e[1;36m'
Cya='\e[0;36m'

OPTION=$1
EC2_CLI='/usr/bin/aws ec2'

# Check id aws cli is installed
if [[ ! -f /usr/bin/aws ]]; then
        echo "Missing AWS CLI tools. Please Install AWS CLI and Retry."
        exit 1
fi

# Check if input/output selection is valid

if [[ $OPTION != @(--volume-list|--volume-attributes|--volume-status) ]];then
        usage
        exit 1
fi

# Check for valid instance id's.

$EC2_CLI describe-instances --query 'Reservations[*].Instances[*].InstanceId'|tr '\n' ' ' > /dev/shm/valid_instances

# prompt user to inpt the instance ids.

echo " "
read -e -p "$(echo -e "${BYel}Enter the Instance IDs (if multiple, must be space separated) : \e[0m")" -a INSTANCE_IDS
echo " "

# Check if the instance id's are valid

for INSTANCE_ID in ${INSTANCE_IDS[@]};do
        if ! grep -qw "$INSTANCE_ID" /dev/shm/valid_instances ;then
                echo " "
                echo -e "${BRed}Error : Either/All - Instance ID's are not valid. \e[0m"
                echo -e "       ${BRed} Re-run the script with valid Instance ID's. \e[0m"
                exit 1
        fi
done

# Loop the tasks for multiple instances

for INSTANCE_ID in ${INSTANCE_IDS[@]};do
        INSTANCE_NAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" --output text | grep Name | awk '{print $NF}')

        if [[ $1 == "--volume-list" ]];then
                echo -e "${BYel}------------------------------------------------- \e[0m"
                echo -e "${BCya}INSTANCE ID        :       $INSTANCE_ID \e[0m"
                echo -e "${BCya}INSTANCE NAME      :       $INSTANCE_NAME \e[0m"
                echo -e "${BYel}------------------------------------------------- \e[0m"
                echo "following volumes are attached to the instance. "
                attached_volume "$INSTANCE_ID"
                echo " "
        elif [[ $1 == "--volume-attributes" ]];then
                echo -e "${BYel}------------------------------------------------- \e[0m"
                echo -e "${BCya}INSTANCE ID        :       $INSTANCE_ID \e[0m"
                echo -e "${BCya}INSTANCE NAME      :       $INSTANCE_NAME \e[0m"
                echo -e "${BYel}------------------------------------------------- \e[0m"
                echo "following are attributes of the attached volumes."
                volume_features "$INSTANCE_ID"
                echo " "
        elif [[ $1 == "--volume-status" ]];then
                echo -e "${BYel}------------------------------------------------- \e[0m"
                echo -e "${BCya}INSTANCE ID        :       $INSTANCE_ID \e[0m"
                echo -e "${BCya}INSTANCE NAME      :       $INSTANCE_NAME \e[0m"
                echo -e "${BYel}------------------------------------------------- \e[0m"
                echo "following is the health status check of the attached volumes."
                volume_status "$INSTANCE_ID"
                echo " "
        fi
done

exit 0
