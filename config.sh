token=#insert telegram bot token here
tele_url="https://api.telegram.org/bot${token}"
#curl -s "${tele_url}/getMe"
#curl -s "${tele_url}/getUpdates"| json_reformat
#curl -s "${tele_url}/getUpdates" | jq -r ".result"
#curl -s "${tele_url}/getUpdates" | jq -r ".result[].message.chat.id"
#curl -s "${tele_url}/sendMessage?chat_id=${chat_id}" --data-urlencode "text=I Am BOT Hello Human" | json_reformat
#curl -s "${tele_url}/getUpdates?offset=1517064599"| json_reformat
