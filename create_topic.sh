#!/bin/bash
read -p "Enter bootstrap server : " bootstrap_server

path_file='./topic_partitions_130db742-101b-4f1e-9f76-0efd5dd42f11.log'
path_file_config= '/etc/kafka/client.properties'

topic_name=()
topic_partitions=()

loop=0
while IFS= read -r line; do
    if [ $(expr $loop % 2) == '0' ]; then
        topic_name+=("$line")
    else
        topic_partitions+=("$line")
    fi
   loop=$((loop+1))
done < $path_file

len=${#topic_partitions[@]}
for i in $(seq 0 $((len-1)));
do
    kafka-topics --create --bootstrap-server \
    $bootstrap_server  --partitions ${topic_partitions[$i]} \
    --topic ${topic_name[$i]} --command-config $path_file_config
done