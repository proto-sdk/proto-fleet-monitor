#!/bin/bash

# Test Slack notification format
export GITHUB_TOKEN=${GITHUB_TOKEN:-"your_token_here"}

# Fetch release data
RELEASE_DATA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/btc-mining/proto-fleet/releases/latest")

# Extract information
NEW_VERSION=$(echo "$RELEASE_DATA" | jq -r '.tag_name')
RELEASE_DATE=$(echo "$RELEASE_DATA" | jq -r '.published_at')
RELEASE_URL=$(echo "$RELEASE_DATA" | jq -r '.html_url')
RELEASE_BODY=$(echo "$RELEASE_DATA" | jq -r '.body')

# Truncate release body to 500 characters
TRUNCATED_BODY="${RELEASE_BODY:0:500}"

echo "=== SLACK NOTIFICATION PREVIEW ==="
echo ""
echo "📋 Header:"
echo "  🚀 New Proto Fleet Release: $NEW_VERSION"
echo ""
echo "📊 Fields:"
echo "  Version: $NEW_VERSION"
echo "  Release Date: $RELEASE_DATE"
echo ""
echo "📝 Release Notes (truncated to 500 chars):"
echo "$TRUNCATED_BODY"
echo ""
echo "🔗 Button:"
echo "  [View Release on GitHub] -> $RELEASE_URL"
echo ""
echo "=== MESSAGE VALIDATION ==="
echo "✓ Version: $NEW_VERSION"
echo "✓ Release Date: $RELEASE_DATE"
echo "✓ Release URL: $RELEASE_URL"
echo "✓ Release Body Length: ${#RELEASE_BODY} characters"
echo "✓ Truncated Body Length: ${#TRUNCATED_BODY} characters"
echo ""
echo "=== RAW JSON (for webhook) ==="
# Create JSON with proper escaping
jq -n \
  --arg version "$NEW_VERSION" \
  --arg date "$RELEASE_DATE" \
  --arg url "$RELEASE_URL" \
  --arg body "$TRUNCATED_BODY" \
  '{
    "blocks": [
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": ("🚀 New Proto Fleet Release: " + $version),
          "emoji": true
        }
      },
      {
        "type": "section",
        "fields": [
          {
            "type": "mrkdwn",
            "text": ("*Version:*\n" + $version)
          },
          {
            "type": "mrkdwn",
            "text": ("*Release Date:*\n" + $date)
          }
        ]
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": ("*Release Notes:*\n" + $body)
        }
      },
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": "View Release on GitHub"
            },
            "url": $url
          }
        ]
      }
    ]
  }'
