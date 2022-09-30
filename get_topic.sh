#!/bin/bash

rm -rf topic_partitions_130db742-101b-4f1e-9f76-0efd5dd42f11.log
echo "Example : 'https://node.alldataint.com:8082' " "(HTTP/HTTPS)"
read -p "Enter URL REST : " url
echo -ne '\n'

######## BEGIN
######## NO ENCRYPTION AND AUTHORIZATION
if [ ${url:0:5} != 'https' ]; then

    tes_url=$(curl -sSL -w "%{http_code}" "$url" ) 
    if [ "$tes_url" == '{}200' ]; then
    
    echo "URL does not use SSL" 
    echo -ne '\n'
    topics=$(curl --silent "$url/topics" | jq ".[]") 

    for i in $topics;
    do
        topic_name=$(echo $i | tr -d '"')

        if [ "${topic_name:0:1}" != "_" ];then
            if [ "${topic_name:0:16}" == 'connect-cluster-' ] ||
                [ "${topic_name:0:26}" == 'confluent-audit-log-events' ];then echo "Skip this Process" > /dev/null
            else
                partitions=$(curl --silent "$url/topics/$topic_name" | jq ".partitions | length" )
                echo "Topic Name : " $topic_name 
                echo "Partitions : " $partitions
                echo -ne '\n'
                echo $topic_name >> topic_partitions_130db742-101b-4f1e-9f76-0efd5dd42f11.log
                echo $partitions >> topic_partitions_130db742-101b-4f1e-9f76-0efd5dd42f11.log
            fi
        fi 

    done
        echo 'successfully save with filename "topic_partitions_130db742-101b-4f1e-9f76-0efd5dd42f11.log"'
    else
        echo "ERROR: server returned HTTP code $tes_url"
        echo invalid URL KAFKA REST : "$url/topics"
        exit 1
    fi
    exit 0
fi
######## END

echo "Example : '/var/ssl/private/ca.crt'"
read -p "Enter PATH ca.crt : " ca
echo -ne '\n'

echo "REST kafka using rbac authorization?"
read -p "Enter [y/n] : " answer
echo -ne '\n'

######## BEGIN
#### Using authorization Condition (SSL)
if [ $answer == "y" ];then
    
    echo "Enter user and pass [HIDDEN]"
    echo "Example : 'username:pass@13' (please use colon :)"
    read -s password

    tes_url=$(curl -sSL -w "%{http_code}" "$url" --cacert $ca -u $password)

    if [[ "$tes_url" == '{}200' ]]; then

        topics=$(curl --silent "$url/topics" --cacert $ca -u $password | jq ".[]")
        for i in $topics;
        do
            topic_name=$(echo $i | tr -d '"')

            if [ "${topic_name:0:1}" != "_" ];then
                if [ "${topic_name:0:16}" == 'connect-cluster-' ] ||
                    [ "${topic_name:0:26}" == 'confluent-audit-log-events' ];then echo "Skip this Process" > /dev/null
                else
                    partitions=$(curl --silent "$url/topics/$topic_name" --cacert $ca -u $password | jq ".partitions | length" )
                    echo "Topic Name : " $topic_name 
                    echo "Partitions : " $partitions
                    echo -ne '\n'
                    echo $topic_name >> topic_partitions_130db742-101b-4f1e-9f76-0efd5dd42f11.log
                    echo $partitions >> topic_partitions_130db742-101b-4f1e-9f76-0efd5dd42f11.log
                fi
            fi 

        done
            echo 'successfully save with filename "topic_partitions_130db742-101b-4f1e-9f76-0efd5dd42f11.log"'
    else
            echo "ERROR: server returned HTTP code $tes_url"
            echo invalid URL KAFKA REST : "$url/topics"
            exit 1
    fi
######## END

######## BEGIN
######## No authorization Condition (SSL)
elif [ $answer == "n" ];then
    tes_url=$(curl -sSL -w "%{http_code}" "$url" --cacert $ca)
    if [[ "$tes_url" == '{}200' ]]; then
        topics=$(curl --silent "$url/topics" --cacert $ca | jq ".[]")
            for i in $topics;
            do
                topic_name=$(echo $i | tr -d '"')

                if [ "${topic_name:0:1}" != "_" ];then
                    if [ "${topic_name:0:16}" == 'connect-cluster-' ] ||
                        [ "${topic_name:0:26}" == 'confluent-audit-log-events' ];then echo "Skip this Process" > /dev/null
                    else
                        partitions=$(curl --silent "$url/topics/$topic_name" --cacert $ca | jq ".partitions | length" )
                        echo "Topic Name : " $topic_name 
                        echo "Partitions : " $partitions
                        echo -ne '\n'
                        echo $topic_name >> topic_partitions_130db742-101b-4f1e-9f76-0efd5dd42f11.log
                        echo $partitions >> topic_partitions_130db742-101b-4f1e-9f76-0efd5dd42f11.log
                    fi
                fi 
            done
        echo 'successfully save with filename "topic_partitions_130db742-101b-4f1e-9f76-0efd5dd42f11.log"'
    else
        echo "ERROR: server returned HTTP code $tes_url"
        echo invalid URL KAFKA REST : "$url/topics"
        exit 1
    fi
else
    echo "ERROR, There is something wrong"
fi
######## END