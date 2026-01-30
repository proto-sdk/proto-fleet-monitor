# Next Steps for Proto Fleet Monitor

## Current Status ✅

The Proto Fleet Monitor is fully configured and ready to deploy. All components are in place:

### Completed Setup
- ✅ Repository structure created
- ✅ Version checking script (`check-version.sh`)
- ✅ GitHub Actions workflow (`monitor-version.yml`)
- ✅ Documentation (README.md, CHANGELOG.md)
- ✅ Test notification script created
- ✅ Slack setup guide created

## Required Actions 🔧

### 1. Obtain Slack Webhook URLs
You need to get the webhook URLs that are currently used in the proto-api-docs repository:

**Option A: Copy from proto-api-docs secrets**
```bash
cd ~/proto-api-docs
gh auth login  # If not already authenticated
gh secret list
```

Look for:
- `SLACK_WEBHOOK_PROTO_DOCUMENTATION`
- `SLACK_WEBHOOK_HMOSES`

**Option B: Get from Slack workspace admin**
- Contact the team member who set up the Proto API Monitor
- They can provide the webhook URLs for both channels

### 2. Add Secrets to proto-fleet-monitor Repository

Once you have the webhook URLs:

```bash
cd ~/proto-fleet-monitor

# Authenticate with GitHub CLI
gh auth login

# Set the secrets
gh secret set SLACK_WEBHOOK_PROTO_DOCUMENTATION
# Paste webhook URL when prompted

gh secret set SLACK_WEBHOOK_HMOSES
# Paste webhook URL when prompted

# Verify secrets are set
gh secret list
```

### 3. Test Notifications Locally

Before pushing to GitHub, test the notifications:

```bash
cd ~/proto-fleet-monitor

# Export webhook URLs (use actual URLs)
export SLACK_WEBHOOK_PROTO_DOCUMENTATION="https://hooks.slack.com/services/..."
export SLACK_WEBHOOK_HMOSES="https://hooks.slack.com/services/..."

# Run test script
./test-slack-notifications.sh
```

Check both Slack channels (#proto-documentation and #hmoses) to verify the test notifications appear correctly.

### 4. Initialize Git Repository and Push

```bash
cd ~/proto-fleet-monitor

# Initialize git if not already done
git init

# Add all files
git add .

# Commit
git commit -m "Initial setup: Proto Fleet version monitor with Slack notifications"

# Create GitHub repository (if not exists)
gh repo create proto-sdk/proto-fleet-monitor --public --source=. --remote=origin

# Push to GitHub
git push -u origin main
```

### 5. Enable GitHub Actions

After pushing:
1. Go to https://github.com/proto-sdk/proto-fleet-monitor
2. Click on "Actions" tab
3. Enable workflows if prompted
4. The workflow will run on the schedule (every 3 hours)

### 6. Trigger First Run

To test the workflow immediately:

```bash
cd ~/proto-fleet-monitor

# Trigger workflow manually
gh workflow run monitor-version.yml

# Check workflow status
gh run list --workflow=monitor-version.yml
```

## Expected Behavior

### Initial Run (v0.1.10 detected)
- Workflow detects v0.1.10 as current version
- Creates `last_version.txt` with "0.1.10"
- Sends notifications to both Slack channels announcing monitoring is active

### Subsequent Runs
- Every 3 hours, checks for new releases
- If new version found:
  - Updates `last_version.txt`
  - Sends notifications to both channels with version details
  - Commits the updated version file

### Manual Trigger
- Can be triggered anytime via GitHub Actions UI or `gh workflow run`

## Monitoring and Maintenance

### Check Workflow Runs
```bash
cd ~/proto-fleet-monitor
gh run list --workflow=monitor-version.yml
gh run view [run-id]  # View specific run details
```

### View Logs
```bash
gh run view [run-id] --log
```

### Update Check Interval
Edit `.github/workflows/monitor-version.yml` and change the cron schedule:
```yaml
schedule:
  - cron: '0 */3 * * *'  # Every 3 hours (current)
  # - cron: '0 */6 * * *'  # Every 6 hours
  # - cron: '0 0 * * *'    # Daily at midnight
```

## Files Created

```
proto-fleet-monitor/
├── .github/
│   └── workflows/
│       └── monitor-version.yml          # GitHub Actions workflow
├── check-version.sh                     # Version checking script
├── test-slack-notifications.sh          # Test notification script
├── README.md                            # Main documentation
├── CHANGELOG.md                         # Change history
├── SLACK_SETUP.md                       # Slack setup guide
├── NEXT_STEPS.md                        # This file
└── last_version.txt                     # Will be created on first run
```

## Timeline Estimate

- **Get webhook URLs**: 5-10 minutes
- **Set GitHub secrets**: 2 minutes
- **Test notifications**: 5 minutes
- **Push to GitHub**: 2 minutes
- **Verify workflow**: 5 minutes

**Total**: ~20-30 minutes

## Support

If you encounter issues:
1. Check SLACK_SETUP.md for troubleshooting
2. Review workflow logs: `gh run view --log`
3. Verify secrets are set: `gh secret list`
4. Test script locally before relying on GitHub Actions

---

**Ready to proceed?** Start with step 1 (obtaining webhook URLs) and work through each step sequentially.
