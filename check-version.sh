#!/bin/bash

# Proto Fleet Version Monitor
# Checks for new releases and updates tracking files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/fleet-version.json"
CHANGELOG_FILE="$SCRIPT_DIR/CHANGELOG.md"
GITHUB_API="https://api.github.com/repos/btc-mining/proto-fleet/releases/latest"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Fetch latest release from GitHub
log "Fetching latest Proto Fleet release..."
RELEASE_DATA=$(curl -s "$GITHUB_API")

# Check if API call was successful
if [ -z "$RELEASE_DATA" ] || echo "$RELEASE_DATA" | grep -q "Not Found"; then
    error "Failed to fetch release data from GitHub API"
    exit 1
fi

# Extract release information
NEW_VERSION=$(echo "$RELEASE_DATA" | jq -r '.tag_name // "unknown"')
RELEASE_NAME=$(echo "$RELEASE_DATA" | jq -r '.name // ""')
RELEASE_URL=$(echo "$RELEASE_DATA" | jq -r '.html_url // ""')
RELEASE_DATE=$(echo "$RELEASE_DATA" | jq -r '.published_at // ""')
RELEASE_BODY=$(echo "$RELEASE_DATA" | jq -r '.body // ""')

if [ "$NEW_VERSION" = "unknown" ] || [ -z "$NEW_VERSION" ]; then
    error "Could not extract version from release data"
    exit 1
fi

log "Latest version: $NEW_VERSION"

# Read current version
if [ -f "$VERSION_FILE" ]; then
    CURRENT_VERSION=$(jq -r '.current_version // "unknown"' "$VERSION_FILE")
else
    CURRENT_VERSION="unknown"
fi

log "Current tracked version: $CURRENT_VERSION"

# Update timestamp
CURRENT_TIME=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

# Check if version has changed
if [ "$NEW_VERSION" != "$CURRENT_VERSION" ]; then
    log "🎉 New version detected: $CURRENT_VERSION -> $NEW_VERSION"
    
    # Update version file
    cat > "$VERSION_FILE" << EOF
{
  "current_version": "$NEW_VERSION",
  "last_checked": "$CURRENT_TIME",
  "release_url": "$RELEASE_URL",
  "release_date": "$RELEASE_DATE"
}
EOF
    
    # Update changelog
    CHANGELOG_ENTRY="## $NEW_VERSION - $(date -u +"%Y-%m-%d")

**Release Name:** $RELEASE_NAME
**Release Date:** $RELEASE_DATE
**Release URL:** $RELEASE_URL

### Changes:
$RELEASE_BODY

---

"
    
    # Insert new entry after the "## Version History" line
    if grep -q "## Version History" "$CHANGELOG_FILE"; then
        # Create temp file with new entry
        awk -v entry="$CHANGELOG_ENTRY" '
            /## Version History/ {
                print $0
                print ""
                print entry
                next
            }
            !/\*No versions tracked yet\*/ {print}
        ' "$CHANGELOG_FILE" > "$CHANGELOG_FILE.tmp"
        mv "$CHANGELOG_FILE.tmp" "$CHANGELOG_FILE"
    fi
    
    log "Updated version tracking files"
    
    # Git commit if in a git repository
    if [ -d "$SCRIPT_DIR/.git" ]; then
        cd "$SCRIPT_DIR"
        git add fleet-version.json CHANGELOG.md
        git commit -m "Update Proto Fleet version to $NEW_VERSION" || true
        log "Changes committed to git"
    fi
    
    # Send Slack notification if webhook is configured
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        log "Sending Slack notification..."
        
        SLACK_MESSAGE=$(cat <<EOF
{
  "blocks": [
    {
      "type": "header",
      "text": {
        "type": "plain_text",
        "text": "🚀 New Proto Fleet Release: $NEW_VERSION",
        "emoji": true
      }
    },
    {
      "type": "section",
      "fields": [
        {
          "type": "mrkdwn",
          "text": "*Version:*\n$NEW_VERSION"
        },
        {
          "type": "mrkdwn",
          "text": "*Release Date:*\n$RELEASE_DATE"
        }
      ]
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "*Release Notes:*\n${RELEASE_BODY:0:500}"
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
          "url": "$RELEASE_URL"
        }
      ]
    }
  ]
}
EOF
)
        
        curl -X POST -H 'Content-type: application/json' \
            --data "$SLACK_MESSAGE" \
            "$SLACK_WEBHOOK_URL" || warn "Failed to send Slack notification"
    else
        warn "SLACK_WEBHOOK_URL not set, skipping notification"
    fi
    
    log "✅ Version update complete!"
else
    log "No version change detected (still at $CURRENT_VERSION)"
    
    # Update last checked time
    cat > "$VERSION_FILE" << EOF
{
  "current_version": "$CURRENT_VERSION",
  "last_checked": "$CURRENT_TIME",
  "release_url": "$RELEASE_URL",
  "release_date": "$RELEASE_DATE"
}
EOF
    
    log "Updated last checked timestamp"
fi

log "Monitor check complete"
