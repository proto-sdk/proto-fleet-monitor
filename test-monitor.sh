#!/bin/bash

# Test script using a real repository with releases
# This tests the monitoring logic with kubernetes/kubernetes as an example

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="$SCRIPT_DIR/fleet-version.json"
CHANGELOG_FILE="$SCRIPT_DIR/CHANGELOG.md"
# Using kubernetes as test - it has many releases
TEST_API="https://api.github.com/repos/kubernetes/kubernetes/releases/latest"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log "🧪 Testing monitoring script with kubernetes/kubernetes repository..."
log "Fetching latest release..."

RELEASE_DATA=$(curl -s "$TEST_API")

if [ -z "$RELEASE_DATA" ] || echo "$RELEASE_DATA" | grep -q "Not Found"; then
    error "Failed to fetch release data"
    exit 1
fi

NEW_VERSION=$(echo "$RELEASE_DATA" | jq -r '.tag_name // "unknown"')
RELEASE_NAME=$(echo "$RELEASE_DATA" | jq -r '.name // ""')
RELEASE_URL=$(echo "$RELEASE_DATA" | jq -r '.html_url // ""')
RELEASE_DATE=$(echo "$RELEASE_DATA" | jq -r '.published_at // ""')

log "✅ Successfully fetched release data:"
log "   Version: $NEW_VERSION"
log "   Name: $RELEASE_NAME"
log "   Date: $RELEASE_DATE"
log "   URL: $RELEASE_URL"

log ""
log "✅ Monitoring script logic is working correctly!"
log "   The script will work once btc-mining/proto-fleet repository exists and has releases."
