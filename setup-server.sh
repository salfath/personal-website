#!/bin/bash

# Script untuk setup server sebelum deployment
# Jalankan script ini di server untuk mempersiapkan direktori deployment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Server Setup Script untuk Personal Website${NC}"
echo ""

# Get current user
CURRENT_USER=$(whoami)
CURRENT_HOME=$(eval echo ~$CURRENT_USER)

echo -e "${YELLOW}Current user: ${CURRENT_USER}${NC}"
echo -e "${YELLOW}Home directory: ${CURRENT_HOME}${NC}"
echo ""

# Ask for deployment path
echo -e "${BLUE}Pilih lokasi deployment:${NC}"
echo "1) Home directory (~/www) - Recommended (tidak perlu sudo)"
echo "2) /var/www/html - Untuk production dengan web server"
echo "3) Custom path"
read -p "Pilihan (1/2/3): " choice

case $choice in
    1)
        DEPLOY_BASE="${CURRENT_HOME}/www"
        DEPLOY_PATH="${DEPLOY_BASE}/personal-website"
        USE_SUDO=false
        ;;
    2)
        DEPLOY_BASE="/var/www/html"
        DEPLOY_PATH="${DEPLOY_BASE}/personal-website"
        USE_SUDO=true
        ;;
    3)
        read -p "Masukkan path lengkap (contoh: /opt/websites): " custom_path
        DEPLOY_BASE="${custom_path}"
        DEPLOY_PATH="${DEPLOY_BASE}/personal-website"
        USE_SUDO=false
        ;;
    *)
        echo -e "${RED}❌ Pilihan tidak valid${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}📁 Membuat direktori deployment...${NC}"
echo -e "Base path: ${DEPLOY_BASE}"
echo -e "Deploy path: ${DEPLOY_PATH}"
echo ""

# Create directory
if [ "$USE_SUDO" = true ]; then
    echo -e "${YELLOW}Menggunakan sudo untuk membuat direktori...${NC}"
    sudo mkdir -p "${DEPLOY_PATH}"
    sudo mkdir -p "${DEPLOY_PATH}/backup"
    sudo chown -R "${CURRENT_USER}:${CURRENT_USER}" "${DEPLOY_PATH}"
    sudo chmod -R 755 "${DEPLOY_PATH}"
else
    mkdir -p "${DEPLOY_PATH}"
    mkdir -p "${DEPLOY_PATH}/backup"
    chmod -R 755 "${DEPLOY_PATH}"
fi

# Verify
if [ -d "${DEPLOY_PATH}" ] && [ -w "${DEPLOY_PATH}" ]; then
    echo -e "${GREEN}✅ Direktori berhasil dibuat!${NC}"
    echo ""
    echo -e "${BLUE}📋 Informasi untuk GitHub Secrets:${NC}"
    echo -e "${GREEN}DEPLOY_PATH = ${DEPLOY_BASE}${NC}"
    echo ""
    echo -e "${BLUE}Test permission:${NC}"
    TEST_FILE="${DEPLOY_PATH}/.test_write"
    if touch "${TEST_FILE}" 2>/dev/null && rm "${TEST_FILE}" 2>/dev/null; then
        echo -e "${GREEN}✅ Write permission OK!${NC}"
    else
        echo -e "${RED}❌ Write permission FAILED!${NC}"
        echo -e "${YELLOW}Mencoba memperbaiki permission...${NC}"
        if [ "$USE_SUDO" = true ]; then
            sudo chown -R "${CURRENT_USER}:${CURRENT_USER}" "${DEPLOY_PATH}"
            sudo chmod -R 755 "${DEPLOY_PATH}"
        else
            chmod -R 755 "${DEPLOY_PATH}"
        fi
    fi
    
    echo ""
    echo -e "${BLUE}📊 Informasi direktori:${NC}"
    ls -ld "${DEPLOY_PATH}"
    echo ""
    echo -e "${GREEN}✅ Setup selesai!${NC}"
    echo -e "${YELLOW}Jangan lupa set DEPLOY_PATH di GitHub Secrets menjadi: ${DEPLOY_BASE}${NC}"
else
    echo -e "${RED}❌ Gagal membuat direktori atau tidak memiliki write permission${NC}"
    exit 1
fi

