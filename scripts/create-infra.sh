#!/bin/bash

image_id=ami-02fc24d56bc5f3d67 #ami-09693313102a30b2c
instance_type=t2.micro
vpc_id=vpc-08b950cd8140c7403
key_name=user1
subnet_id=subnet-060d8c5c243f86664
shutdown_type=stop
tags="ResourceType=instance,Tags=[{Key=installation_id,Value=${key_name}-1},{Key=Name,Value=NAME}]" 

# tags="ResourceType=instance,Tags=[{Key=installation_id,Value=user1-1}]"


start_vm()                                                                         
{
  local private_ip_address="$1"
  local public_ip="$2"
  local name="$3"
  local tags=$(echo $tags | sed s/NAME/$name/)  
  
  aws ec2 run-instances \
  --image-id "$image_id" \
  --instance-type "$instance_type" \
  --key-name "$key_name" \
  --subnet-id "$subnet_id" \
  --instance-initiated-shutdown-behavior "$shutdown_type" \
  --private-ip-address "$private_ip_address" \
  --tag-specifications "$tags" \
  --${public_ip}  

}                                                                                
start()                                                                          
{                                                      

# start_vm 10.1.1.101 associate-public-ip-address
# start_vm 10.1.1.102 noassociate-public-ip-address
# done

start_vm 10.1.1.111 associate-public-ip-address user1-vm1
for i in {2..5}; do
start_vm 10.1.1.$((100+i)) no-associate-public-ip-address user1-vm$i
done

}

stop()

{ 
  ids=($(
    aws ec2 describe-instances \
	--query 'Reservations[*].Instances[?KeyName==`'$key_name'`].InstanceId' \
	--output text
  ))
    aws ec2 terminate-instances --instance-ids "${ids[@]}"
}


if [ "$1" = start ]; then
  start
elif [ "$1" = stop ]; then
  stop
else
cat <<EOF

Usage:

$0 start|stop

EOF

fi              
