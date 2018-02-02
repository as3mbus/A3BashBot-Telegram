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

function message_usage() {
    cat <<-EOF
usage:  A3BshBot [options]

operations:
 general
   -v, --version    display version information
   -h, --help       display help information

EOF
}

function message_version() {
  local version='v0.001'
    echo "cupubot $version"
}

function get_options_from_arguments() {   
    # ! : indirect expansion
    while [[ -n "${!OPTIND}" ]]; do
        case "${!OPTIND}" in
            version)   
                message_version
                exit;;
        esac

        shift $OPTIND
        OPTIND=1
    done
}

### -- last update --
# save last message id.
last_id_file=$BASEDIR/id.txt
last_id=0

if [ ! -f $last_id_file ];
then
    touch $last_id_file
    echo 0 > $last_id_file    
else
    last_id=$(cat $last_id_file)
    # echo "last id = $last_id"
fi

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
function process_reply_all_message() {
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
# send reply to messages after certain offset
function process_reply() {
  # global-project : last_id
  # global-module  : _
  local i update message_id chat_id text

    local updates=$(curl -s "${tele_url}/getUpdates?offset=$last_id")
    local count_update=$(echo $updates | jq -r ".result | length") 
    
    [[ $count_update -eq 0 ]] && echo -n "."

    for ((i=0; i<$count_update; i++)); do
        update=$(echo $updates | jq -r ".result[$i]")   
        last_id=$(echo $update | jq -r ".update_id")     
        message_id=$(echo $update | jq -r ".message.message_id")    
        chat_id=$(echo $update | jq -r ".message.chat.id") 
        
        get_feedback_reply "$update"
    
        result=$(curl -s "${tele_url}/sendMessage" \
                  --data-urlencode "chat_id=${chat_id}" \
                  --data-urlencode "reply_to_message_id=${message_id}" \
                  --data-urlencode "text=$return_feedback"
            );

        last_id=$(($last_id + 1))            
        echo $last_id > $last_id_file
        
        echo -e "\n: ${text}"
    done
}

# read nessage and set reply based on first word of message
function get_feedback_reply() {
  # global-module  : return_feedback
    local update=$1
    
    text=$(echo $update | jq -r ".message.text")   
  local first_word=$(echo $text | head -n 1 | awk '{print $1;}')
  
  return_feedback='Good message !'
  case $first_word in
        '/id') 
            username=$(echo $update | jq -r ".message.chat.username")
            return_feedback="You are the mighty @${username}"
        ;;
        *)
            return_feedback='Thank you for your message.'            
        ;;
    esac
}

### -- controller --

function do_observe() {
  # no loop
    process_observe
} 
function do_reply() {
    process_reply
}
function loop_reply() {
    while true; do 
        process_reply   
        sleep 1
    done
}

### -- main --

get_options_from_arguments "$@"

