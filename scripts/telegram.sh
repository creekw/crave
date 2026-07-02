#!/bin/bash

# Ensure secrets are passed as environment variables
if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
  echo "Error: TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID environment variables are required."
  exit 1
fi

API_URL="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}"

# 1. Send the initial message
echo "Sending initial Telegram message..."
RESPONSE=$(curl -s -X POST "${API_URL}/sendMessage" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  -d text="⏳ Action started: Processing data...")

# 2. Parse the message_id from the response using jq
MESSAGE_ID=$(echo "$RESPONSE" | jq '.result.message_id')

# Verify the message was sent successfully
if [ -z "$MESSAGE_ID" ] || [ "$MESSAGE_ID" == "null" ]; then
  echo "Failed to send message. API Response:"
  echo "$RESPONSE"
  exit 1
fi

echo "Message sent successfully with ID: $MESSAGE_ID"

# --- SIMULATE YOUR WORKLOAD HERE ---
echo "Doing work..."
sleep 5
# -----------------------------------

# 3. Edit the existing message
echo "Updating Telegram message..."
curl -s -X POST "${API_URL}/editMessageText" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  -d message_id="${MESSAGE_ID}" \
  -d text="✅ Action complete: Data processed successfully!"
