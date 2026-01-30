# Proto Fleet Version Monitor

Automated monitoring system for tracking Proto Fleet releases from GitHub.

## Overview

This system monitors the [btc-mining/proto-fleet](https://github.com/btc-mining/proto-fleet) repository for new releases and automatically:
- Tracks version changes
- Updates changelog
- Sends Slack notifications
- Commits changes to git

## Files

- **check-version.sh** - Main monitoring script
- **fleet-version.json** - Current version tracking data
- **CHANGELOG.md** - Version history log
- **index.html** - Simple web page displaying current version
- **.github/workflows/monitor-version.yml** - GitHub Actions workflow

## Setup Instructions

### 1. Local Testing

Before pushing to GitHub, test the monitoring script locally:

```bash
cd ~/proto-fleet-monitor
./check-version.sh
```

This will fetch the latest version and update the tracking files.

### 2. GitHub Repository Setup

1. Create a new GitHub repository (e.g., `proto-fleet-monitor`)
2. Initialize git and push:

```bash
cd ~/proto-fleet-monitor
git init
git add .
git commit -m "Initial commit: Proto Fleet version monitor"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/proto-fleet-monitor.git
git push -u origin main
```

### 3. Configure GitHub Secrets

Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):

- **SLACK_WEBHOOK_URL** - Your Slack webhook URL for notifications (optional)

### 4. GitHub Token

The workflow uses the default `GITHUB_TOKEN` which has permissions to commit back to the repository. No additional PAT is needed for the workflow itself.

If you want to use a PAT for pushing:
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Create a token with `repo` scope
3. Add it as a secret named `GH_PAT`
4. Update the workflow to use `token: ${{ secrets.GH_PAT }}`

## How It Works

### Monitoring Schedule

The GitHub Actions workflow runs:
- **Every 3 hours** (via cron schedule)
- **On manual trigger** (via workflow_dispatch)
- **On push to main** (for testing)

### Version Check Process

1. Fetches latest release from GitHub API: `https://api.github.com/repos/btc-mining/proto-fleet/releases/latest`
2. Compares `tag_name` with stored version in `fleet-version.json`
3. If version changed:
   - Updates `fleet-version.json` with new version info
   - Adds entry to `CHANGELOG.md` with release notes
   - Commits changes to git
   - Sends Slack notification (if configured)
4. If no change:
   - Updates `last_checked` timestamp only

### Slack Notifications

When a new version is detected, the system sends a formatted Slack message with:
- Version number
- Release date
- Release notes excerpt
- Link to GitHub release

## Manual Testing

### Test the script locally:

```bash
cd ~/proto-fleet-monitor
./check-version.sh
```

### Test with Slack notifications:

```bash
export SLACK_WEBHOOK_URL="your-webhook-url"
./check-version.sh
```

### View the web page:

```bash
cd ~/proto-fleet-monitor
python3 -m http.server 8000
# Open http://localhost:8000 in browser
```

## Monitoring

### Check workflow runs:
- Go to your GitHub repository
- Click "Actions" tab
- View "Proto Fleet Version Monitor" workflow runs

### View current version:
- Check `fleet-version.json` in the repository
- View the GitHub Pages site (if enabled)
- Check `CHANGELOG.md` for history

## Troubleshooting

### Script fails to fetch release:
- Check if the repository URL is correct
- Verify GitHub API is accessible
- Check rate limiting (60 requests/hour for unauthenticated)

### Git push fails:
- Verify repository permissions
- Check if GitHub token has correct scopes
- Ensure workflow has write permissions

### Slack notifications not working:
- Verify `SLACK_WEBHOOK_URL` secret is set
- Test webhook URL manually
- Check Slack app permissions

## Customization

### Change monitoring frequency:

Edit `.github/workflows/monitor-version.yml`:
```yaml
schedule:
  - cron: '0 */3 * * *'  # Change to desired schedule
```

### Monitor different repository:

Edit `check-version.sh`:
```bash
GITHUB_API="https://api.github.com/repos/OWNER/REPO/releases/latest"
```

## License

MIT License - Feel free to use and modify as needed.
