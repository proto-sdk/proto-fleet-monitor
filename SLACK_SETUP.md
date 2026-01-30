# Slack Notification Setup Guide

## Overview
This guide explains how to set up and test Slack notifications for Proto Fleet version monitoring.

## Webhook URLs Needed

You need two Slack webhook URLs (these should already exist from the Proto API Monitor setup):

1. **#proto-documentation channel**: `SLACK_WEBHOOK_PROTO_DOCUMENTATION`
2. **#hmoses channel**: `SLACK_WEBHOOK_HMOSES`

## Getting the Webhook URLs

### Option 1: From GitHub Secrets (Recommended)
If you have access to the proto-api-docs repository secrets:

```bash
# View secrets in proto-api-docs repository
cd ~/proto-api-docs
gh secret list

# The secrets you need are:
# - SLACK_WEBHOOK_PROTO_DOCUMENTATION
# - SLACK_WEBHOOK_HMOSES
```

### Option 2: From Slack Workspace
If you need to create new webhooks or retrieve existing ones:

1. Go to https://api.slack.com/apps
2. Select your workspace app
3. Navigate to "Incoming Webhooks"
4. Find or create webhooks for:
   - #proto-documentation
   - #hmoses

## Setting Up GitHub Secrets

Add the webhook URLs as secrets to the proto-fleet-monitor repository:

```bash
cd ~/proto-fleet-monitor

# Set the secrets (replace with actual webhook URLs)
gh secret set SLACK_WEBHOOK_PROTO_DOCUMENTATION
# Paste the webhook URL when prompted

gh secret set SLACK_WEBHOOK_HMOSES
# Paste the webhook URL when prompted
```

## Testing Notifications Locally

To test the notifications before committing:

```bash
cd ~/proto-fleet-monitor

# Export the webhook URLs as environment variables
export SLACK_WEBHOOK_PROTO_DOCUMENTATION="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
export SLACK_WEBHOOK_HMOSES="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# Run the test script
./test-slack-notifications.sh
```

Expected output:
```
Sending test notification to #proto-documentation...
✓ Successfully sent to #proto-documentation

Sending test notification to #hmoses...
✓ Successfully sent to #hmoses

✓ All test notifications sent successfully!
```

## Notification Format

The test notification includes:
- 🚀 Header: "Proto Fleet Monitoring Active!"
- Version: v0.1.10
- Status: ✅ Monitoring Active
- Check Interval: Every 3 hours
- Repository: block/proto-fleet
- Three action buttons:
  - "View Release" (primary) - Links to v0.1.10 release
  - "View Repository" - Links to block/proto-fleet
  - "View Monitor" - Links to proto-fleet-monitor repo
- Timestamp footer with test notification indicator

## Verifying GitHub Workflow

Once secrets are set, verify the workflow will work:

```bash
cd ~/proto-fleet-monitor

# Check that secrets are referenced in the workflow
grep -A 5 "SLACK_WEBHOOK" .github/workflows/monitor-version.yml
```

## Next Steps

1. ✅ Get webhook URLs from proto-api-docs secrets or Slack workspace
2. ✅ Add secrets to proto-fleet-monitor repository
3. ✅ Test notifications locally using test-slack-notifications.sh
4. ✅ Verify notifications appear in both Slack channels
5. ✅ Commit and push the workflow to enable automated monitoring

## Troubleshooting

### Error: "SLACK_WEBHOOK_* environment variable not set"
- Make sure you've exported the webhook URLs as environment variables
- Check that the URLs are valid and not expired

### Error: "Failed to send to #channel"
- Verify the webhook URL is correct
- Check that the webhook is still active in Slack
- Ensure you have proper permissions in the Slack workspace

### No notification received in Slack
- Check the webhook URL is for the correct channel
- Verify the webhook hasn't been revoked
- Check Slack workspace settings for incoming webhooks

## Contact

If you need help accessing the webhook URLs, contact the team member who set up the Proto API Monitor notifications.
