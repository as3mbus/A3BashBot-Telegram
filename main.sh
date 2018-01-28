#!/usr/bin/env bash

### -- config -- 

# $token variable here in config.sh
BASEDIR=$(dirname "$0")
config_file=$BASEDIR/config.sh

if [ ! -f $config_file ];
then
    echo "Config not found!" && exit 0
else
    source $config_file
fi

tele_url="https://api.telegram.org/bot${token}"

### -- task -- 
# get updates from telegram bot through curl request
function process_observe() {
    local i update
    # updates store every response from server
    local updates=$(curl -s "${tele_url}/getUpdates")
    # count number of message / update from updates response earlier
    local count_update=$(echo $updates | jq -r ".result | length") 
    
    # iterate through update and echo it
    for ((i=0; i<$count_update; i++)); do
        update=$(echo $updates | jq -r ".result[$i]")
        echo "$update\n"
    done
}
# send reply to every message ?
function process_reply() {
  local i update message_id chat_id
    local updates=$(curl -s "${tele_url}/getUpdates")
    local count_update=$(echo $updates | jq -r ".result | length") 
    
    for ((i=0; i<$count_update; i++)); do
        update=$(echo $updates | jq -r ".result[$i]")
    
        message_id=$(echo $update | jq -r ".message.message_id")     
        chat_id=$(echo $update | jq -r ".message.chat.id") 
           
        result=$(curl -s "${tele_url}/sendMessage" \
                  --data-urlencode "chat_id=${chat_id}" \
                  --data-urlencode "reply_to_message_id=${message_id}" \
                  --data-urlencode "text=Thank you for your message."
            );
    done
}

### -- controller --

function do_observe() {
  # no loop
    process_observe
} 
function do_reply() {
    process_reply
}

### -- main --

do_reply
