#!/bin/bash

# Quick Start Script for Proto Fleet Monitor
# This script guides you through the setup process

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Proto Fleet Monitor - Quick Start Setup    ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Check if in correct directory
if [ ! -f "check-version.sh" ]; then
    echo -e "${RED}Error: Please run this script from the proto-fleet-monitor directory${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1: Checking GitHub CLI authentication...${NC}"
if gh auth status &>/dev/null; then
    echo -e "${GREEN}✓ GitHub CLI is authenticated${NC}"
else
    echo -e "${YELLOW}⚠ GitHub CLI not authenticated. Running 'gh auth login'...${NC}"
    gh auth login
fi
echo ""

# Step 2: Check for secrets in proto-api-docs
echo -e "${YELLOW}Step 2: Checking for existing Slack webhooks in proto-api-docs...${NC}"
if [ -d "../proto-api-docs" ]; then
    echo -e "${BLUE}Found proto-api-docs repository. Checking secrets...${NC}"
    cd ../proto-api-docs
    echo -e "${BLUE}Available secrets:${NC}"
    gh secret list 2>&1 || echo -e "${YELLOW}Could not list secrets. You may need repository access.${NC}"
    cd - > /dev/null
else
    echo -e "${YELLOW}⚠ proto-api-docs not found in parent directory${NC}"
fi
echo ""

# Step 3: Prompt for webhook URLs
echo -e "${YELLOW}Step 3: Setting up Slack webhook secrets...${NC}"
echo -e "${BLUE}You need two webhook URLs:${NC}"
echo -e "  1. SLACK_WEBHOOK_PROTO_DOCUMENTATION (for #proto-documentation)"
echo -e "  2. SLACK_WEBHOOK_HMOSES (for #hmoses)"
echo ""

read -p "Do you have the webhook URLs ready? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Please obtain the webhook URLs first. See SLACK_SETUP.md for details.${NC}"
    echo -e "${BLUE}Exiting setup. Run this script again when you have the URLs.${NC}"
    exit 0
fi

# Set secrets
echo -e "${BLUE}Setting SLACK_WEBHOOK_PROTO_DOCUMENTATION...${NC}"
gh secret set SLACK_WEBHOOK_PROTO_DOCUMENTATION

echo -e "${BLUE}Setting SLACK_WEBHOOK_HMOSES...${NC}"
gh secret set SLACK_WEBHOOK_HMOSES

echo -e "${GREEN}✓ Secrets set successfully${NC}"
echo ""

# Step 4: Test notifications locally
echo -e "${YELLOW}Step 4: Testing notifications locally (optional)...${NC}"
read -p "Would you like to test notifications now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Please export the webhook URLs as environment variables:${NC}"
    echo ""
    echo -e "${YELLOW}export SLACK_WEBHOOK_PROTO_DOCUMENTATION='your-webhook-url'${NC}"
    echo -e "${YELLOW}export SLACK_WEBHOOK_HMOSES='your-webhook-url'${NC}"
    echo ""
    echo -e "${BLUE}Then run: ./test-slack-notifications.sh${NC}"
    echo ""
    read -p "Press Enter when ready to continue..."
fi
echo ""

# Step 5: Git setup
echo -e "${YELLOW}Step 5: Git repository setup...${NC}"

if [ -d ".git" ]; then
    echo -e "${GREEN}✓ Git repository already initialized${NC}"
else
    echo -e "${BLUE}Initializing git repository...${NC}"
    git init
    echo -e "${GREEN}✓ Git initialized${NC}"
fi

# Check if remote exists
if git remote get-url origin &>/dev/null; then
    echo -e "${GREEN}✓ Remote 'origin' already configured${NC}"
    REMOTE_URL=$(git remote get-url origin)
    echo -e "${BLUE}Remote URL: ${REMOTE_URL}${NC}"
else
    echo -e "${YELLOW}No remote configured.${NC}"
    read -p "Create GitHub repository proto-sdk/proto-fleet-monitor? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gh repo create proto-sdk/proto-fleet-monitor --public --source=. --remote=origin
        echo -e "${GREEN}✓ GitHub repository created${NC}"
    fi
fi
echo ""

# Step 6: Commit and push
echo -e "${YELLOW}Step 6: Commit and push changes...${NC}"

# Check if there are uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${BLUE}Uncommitted changes detected. Creating commit...${NC}"
    git add .
    git commit -m "Initial setup: Proto Fleet version monitor with Slack notifications

- Added version checking script (check-version.sh)
- Added GitHub Actions workflow (monitor-version.yml)
- Added test notification script
- Added comprehensive documentation
- Configured Slack notifications for #proto-documentation and #hmoses
- Set up monitoring for block/proto-fleet releases
- Check interval: every 3 hours"
    echo -e "${GREEN}✓ Changes committed${NC}"
else
    echo -e "${GREEN}✓ No uncommitted changes${NC}"
fi

read -p "Push to GitHub? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git push -u origin main || git push -u origin master
    echo -e "${GREEN}✓ Pushed to GitHub${NC}"
fi
echo ""

# Step 7: Enable and trigger workflow
echo -e "${YELLOW}Step 7: GitHub Actions workflow...${NC}"
echo -e "${BLUE}The workflow will run automatically every 3 hours.${NC}"
echo ""

read -p "Trigger the workflow now for initial test? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Triggering workflow...${NC}"
    gh workflow run monitor-version.yml
    echo -e "${GREEN}✓ Workflow triggered${NC}"
    echo ""
    echo -e "${BLUE}Checking workflow status...${NC}"
    sleep 3
    gh run list --workflow=monitor-version.yml --limit 5
fi
echo ""

# Summary
echo -e "${GREEN}╔═══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            Setup Complete! 🎉                 ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Check Slack channels for test notifications"
echo -e "  2. Monitor workflow runs: ${YELLOW}gh run list --workflow=monitor-version.yml${NC}"
echo -e "  3. View workflow logs: ${YELLOW}gh run view [run-id] --log${NC}"
echo -e "  4. Repository: ${YELLOW}https://github.com/proto-sdk/proto-fleet-monitor${NC}"
echo ""
echo -e "${BLUE}Documentation:${NC}"
echo -e "  - README.md - Main documentation"
echo -e "  - SLACK_SETUP.md - Slack configuration guide"
echo -e "  - NEXT_STEPS.md - Detailed next steps"
echo -e "  - CHANGELOG.md - Version history"
echo ""
echo -e "${GREEN}The monitor will check for new Proto Fleet releases every 3 hours!${NC}"
