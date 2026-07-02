#!/bin/bash

if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
  echo "Error: TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID environment variables are required."
  exit 1
fi


API_URL="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}"

if [ "$1" == "EDIT" ]; then
  MESSAGE_ID="$2"
  CONTENT="$3"

  if [ -z "$MESSAGE_ID" ]; then
    echo "Error: MESSAGE_ID is required for editing."
    exit 1
  fi

  if [ -z "$CONTENT" ]; then
    echo "Error: CONTENT is required for editing the message."
    exit 1
  fi

  if [ ! -f "$CONTENT" ]; then
    echo "Error: CONTENT file '$CONTENT' does not exist."
    exit 1
  fi

  CONTENT_TEXT=$(cat "$CONTENT")

  echo "Editing Telegram message with ID: $MESSAGE_ID..."
  RESPONSE=$(curl -s -X POST "${API_URL}/editMessageText" \
    -d chat_id="${TELEGRAM_CHAT_ID}" \
    -d message_id="${MESSAGE_ID}" \
    --data-urlencode text="$CONTENT_TEXT")

  if [[ $(echo "$RESPONSE" | jq '.ok') == "true" ]];
  then
    echo "Message edited successfully."
    exit 0
  else
    echo "Failed to edit message. API Response:"
    echo "$RESPONSE"
    exit 1
  fi
fi


#################################
# Otherwise, send a new message #
#################################

if [ -z "$1" ]; then
  echo "Error: CONTENT_FILE is required as the first argument."
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "Error: CONTENT_FILE '$1' does not exist."
  exit 1
fi

CONTENT_TEXT=$(cat "$1")

echo "Sending Telegram message..."
RESPONSE=$(curl -s -X POST "${API_URL}/sendMessage" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  --data-url-encode text="$CONTENT_TEXT")

MESSAGE_ID=$(echo "$RESPONSE" | jq -r '.result.message_id')

echo "MESSAGE_ID=$MESSAGE_ID" >> "$GITHUB_OUTPUT"

if [ -z "$MESSAGE_ID" ] || [ "$MESSAGE_ID" == "null" ]; then
  echo "Failed to send message. API Response:"
  echo "$RESPONSE"
  exit 1
fi

echo "Message sent successfully with ID: $MESSAGE_ID"
