#!/bin/bash

# Deployment script untuk manual deployment
# Script ini juga bisa digunakan sebagai referensi untuk GitHub Actions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting deployment...${NC}"

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo -e "${YELLOW}⚠️  .env file not found. Using environment variables...${NC}"
fi

# Check required variables
if [ -z "$SERVER_IP" ] || [ -z "$SSH_USER" ] || [ -z "$DEPLOY_PATH" ]; then
    echo -e "${RED}❌ Error: SERVER_IP, SSH_USER, and DEPLOY_PATH must be set${NC}"
    exit 1
fi

# Setup SSH
echo -e "${GREEN}📡 Setting up SSH connection...${NC}"
mkdir -p ~/.ssh
chmod 700 ~/.ssh

if [ -n "$SSH_PRIVATE_KEY" ]; then
    echo "$SSH_PRIVATE_KEY" > ~/.ssh/deploy_key
    chmod 600 ~/.ssh/deploy_key
    SSH_OPTIONS="-i ~/.ssh/deploy_key"
else
    echo -e "${YELLOW}⚠️  SSH_PRIVATE_KEY not set, using password authentication${NC}"
    SSH_OPTIONS=""
fi

# Add server to known hosts
ssh-keyscan -H "$SERVER_IP" >> ~/.ssh/known_hosts 2>/dev/null || true

# Create deployment directory
echo -e "${GREEN}📁 Creating deployment directory...${NC}"
ssh $SSH_OPTIONS -o StrictHostKeyChecking=no "$SSH_USER@$SERVER_IP" << EOF
    mkdir -p "$DEPLOY_PATH/personal-website"
    mkdir -p "$DEPLOY_PATH/personal-website/backup"
EOF

# Backup existing files
echo -e "${GREEN}💾 Creating backup...${NC}"
ssh $SSH_OPTIONS -o StrictHostKeyChecking=no "$SSH_USER@$SERVER_IP" << EOF
    if [ -d "$DEPLOY_PATH/personal-website" ]; then
        TIMESTAMP=\$(date +%Y%m%d_%H%M%S)
        cp -r "$DEPLOY_PATH/personal-website"/* "$DEPLOY_PATH/personal-website/backup/\$TIMESTAMP/" 2>/dev/null || true
        echo "Backup created at: backup/\$TIMESTAMP/"
    fi
EOF

# Deploy files
echo -e "${GREEN}📤 Deploying files...${NC}"
rsync -avz --delete \
    -e "ssh $SSH_OPTIONS -o StrictHostKeyChecking=no" \
    --exclude='.git' \
    --exclude='.github' \
    --exclude='node_modules' \
    --exclude='.gitignore' \
    --exclude='package.json' \
    --exclude='package-lock.json' \
    --exclude='.env' \
    --exclude='deploy.sh' \
    ./ "$SSH_USER@$SERVER_IP:$DEPLOY_PATH/personal-website/"

# Verify deployment
echo -e "${GREEN}✅ Verifying deployment...${NC}"
ssh $SSH_OPTIONS -o StrictHostKeyChecking=no "$SSH_USER@$SERVER_IP" << EOF
    if [ -f "$DEPLOY_PATH/personal-website/index.html" ]; then
        echo "✅ Deployment successful!"
        echo "Files deployed to: $DEPLOY_PATH/personal-website/"
        ls -la "$DEPLOY_PATH/personal-website/"
    else
        echo "❌ Deployment failed - index.html not found"
        exit 1
    fi
EOF

# Cleanup
if [ -f ~/.ssh/deploy_key ]; then
    rm -f ~/.ssh/deploy_key
fi

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"

