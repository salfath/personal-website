# Panduan Deployment dengan GitHub Actions

Dokumen ini menjelaskan cara setup CI/CD menggunakan GitHub Actions untuk deployment otomatis ke server.

## Prerequisites

1. Repository GitHub sudah dibuat
2. Server dengan akses SSH tersedia
3. SSH key atau password untuk akses server

## Quick Start (Setup Cepat)

**Langkah 1: Setup Server**
```bash
# Login ke server
ssh user@server_ip

# Buat direktori deployment (pilih salah satu)

# Opsi A - Home directory (Paling Mudah):
mkdir -p ~/www
# Catat path lengkap: /home/username/www (ganti username dengan SSH_USER Anda)

# Opsi B - /var/www/html:
sudo mkdir -p /var/www/html/personal-website
sudo chown -R $USER:$USER /var/www/html/personal-website
# Catat path: /var/www/html
```

**Langkah 2: Setup GitHub Secrets**
1. Buka GitHub → Repository → Settings → Secrets and variables → Actions
2. Tambahkan secrets berikut:
   - `SERVER_IP` = IP server Anda
   - `SSH_USER` = Username SSH (contoh: `ubuntu`, `root`)
   - `SSH_PRIVATE_KEY` = Private SSH key (lihat cara membuat di bawah)
   - `DEPLOY_PATH` = Path dari Langkah 1 (contoh: `/home/ubuntu/www` atau `/var/www/html`)

**Langkah 3: Push ke Repository**
```bash
git push origin main
```

Deployment akan otomatis berjalan! Lihat status di tab **Actions** di GitHub.

---

## Setup GitHub Secrets

Untuk menggunakan GitHub Actions, Anda perlu mengatur secrets berikut di repository GitHub:

### Cara Menambahkan Secrets

1. Buka repository GitHub Anda
2. Klik **Settings** → **Secrets and variables** → **Actions**
3. Klik **New repository secret**
4. Tambahkan secrets berikut satu per satu:

### Secrets yang Diperlukan

#### 1. `SERVER_IP`
- **Deskripsi**: IP address atau hostname server tujuan
- **Contoh**: `192.168.1.100` atau `server.example.com`
- **Cara mendapatkan**: 
  ```bash
  # Di server, jalankan:
  hostname -I
  # atau
  curl ifconfig.me
  ```

#### 2. `SSH_USER`
- **Deskripsi**: Username untuk SSH login ke server
- **Contoh**: `root`, `ubuntu`, `deploy`, atau username lainnya
- **Catatan**: Pastikan user memiliki permission untuk menulis di direktori deployment

#### 3. `SSH_PRIVATE_KEY`
- **Deskripsi**: Private SSH key untuk autentikasi (recommended)
- **Cara membuat SSH key**:

  **Untuk Windows PowerShell:**
  ```powershell
  # Pastikan direktori .ssh ada
  if (-not (Test-Path "$env:USERPROFILE\.ssh")) {
      New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh"
  }
  
  # Generate SSH key
  ssh-keygen -t rsa -b 4096 -C "github-actions-deploy" -f "$env:USERPROFILE\.ssh\github_deploy_key"
  
  # Copy public key ke server (ganti user@server_ip dengan credentials Anda)
  type "$env:USERPROFILE\.ssh\github_deploy_key.pub" | ssh user@server_ip "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
  
  # Tampilkan private key untuk di-copy ke GitHub Secrets
  Get-Content "$env:USERPROFILE\.ssh\github_deploy_key"
  ```

  **Untuk Linux/Mac (Bash):**
  ```bash
  # Di local machine, jalankan:
  ssh-keygen -t rsa -b 4096 -C "github-actions-deploy" -f ~/.ssh/github_deploy_key
  
  # Copy public key ke server:
  ssh-copy-id -i ~/.ssh/github_deploy_key.pub user@server_ip
  
  # Copy private key (isi dari github_deploy_key) ke GitHub Secrets
  cat ~/.ssh/github_deploy_key
  ```
- **Alternatif**: Jika menggunakan password, lihat bagian alternatif di bawah

#### 4. `DEPLOY_PATH`
- **Deskripsi**: Path direktori di server tempat file akan di-deploy
- **Contoh yang benar**:
  - `/var/www/html` - Untuk web server standar (perlu sudo atau permission khusus)
  - `/home/ubuntu/www` - Untuk user ubuntu (ganti dengan SSH_USER Anda)
  - `/home/user/www` - Untuk user biasa
  - `/opt/websites` - Alternatif lokasi
- **Contoh yang SALAH**:
  - `/` - Root directory (tidak boleh)
  - `/personal-website` - Tanpa parent directory
  - `~/www` - Tilde tidak bekerja di GitHub Actions
- **Cara setup**:
  1. Login ke server: `ssh user@server_ip`
  2. Buat direktori: `mkdir -p ~/www` (atau path lain yang Anda pilih)
  3. Set DEPLOY_PATH di GitHub Secrets: `/home/username/www` (ganti username dengan SSH_USER)
  4. Pastikan user memiliki write permission ke direktori tersebut

### Alternatif: Menggunakan Password (Tidak Recommended)

Jika Anda tidak ingin menggunakan SSH key, Anda bisa menggunakan password. Namun, ini kurang aman. Untuk menggunakan password:

1. Install `sshpass` di GitHub Actions runner (tambahkan di workflow):
   ```yaml
   - name: Install sshpass
     run: sudo apt-get update && sudo apt-get install -y sshpass
   ```

2. Tambahkan secret `SSH_PASSWORD` di GitHub Secrets

3. Modifikasi workflow untuk menggunakan password (tidak disarankan untuk production)

## Setup Server

Sebelum deployment, pastikan server sudah dikonfigurasi dengan benar:

### 1. Install Web Server (jika belum ada)

**Nginx:**
```bash
sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
```

**Apache:**
```bash
sudo apt update
sudo apt install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
```

### 2. Buat Direktori Deployment

**Cara Otomatis (Menggunakan Script Helper):**

```bash
# Upload script ke server atau clone repository
scp setup-server.sh user@server_ip:~/
ssh user@server_ip
chmod +x setup-server.sh
./setup-server.sh
# Script akan memandu Anda melalui proses setup
```

**Cara Manual:**

**Opsi 1: Menggunakan direktori di home user (Recommended - Lebih Mudah)**

```bash
# Login ke server
ssh user@server_ip

# Buat direktori di home user (tidak perlu sudo)
mkdir -p ~/www/personal-website
mkdir -p ~/www/personal-website/backup

# Set DEPLOY_PATH di GitHub Secrets menjadi:
# /home/username/www (ganti username dengan SSH_USER Anda)
# Contoh: Jika SSH_USER adalah "ubuntu", maka DEPLOY_PATH = /home/ubuntu/www
```

**Opsi 2: Menggunakan /var/www/html (Perlu Permission Khusus)**

```bash
# Login ke server sebagai root atau user dengan sudo
ssh user@server_ip

# Buat direktori
sudo mkdir -p /var/www/html/personal-website
sudo mkdir -p /var/www/html/personal-website/backup

# Set ownership ke SSH_USER (ganti ubuntu dengan SSH_USER Anda)
sudo chown -R ubuntu:ubuntu /var/www/html/personal-website
sudo chmod -R 755 /var/www/html/personal-website

# Atau jika menggunakan www-data group:
sudo chown -R ubuntu:www-data /var/www/html/personal-website
sudo chmod -R 775 /var/www/html/personal-website

# Set DEPLOY_PATH di GitHub Secrets menjadi: /var/www/html
```

**Verifikasi Permission:**

```bash
# Test apakah user bisa menulis
touch ~/www/personal-website/test.txt
rm ~/www/personal-website/test.txt

# Jika berhasil, permission sudah benar
```

### 3. Konfigurasi Web Server

**Nginx Configuration** (`/etc/nginx/sites-available/personal-website`):
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    root /var/www/html/personal-website;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

Aktifkan konfigurasi:
```bash
sudo ln -s /etc/nginx/sites-available/personal-website /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

**Apache Configuration** (`/etc/apache2/sites-available/personal-website.conf`):
```apache
<VirtualHost *:80>
    ServerName your-domain.com
    ServerAlias www.your-domain.com
    DocumentRoot /var/www/html/personal-website

    <Directory /var/www/html/personal-website>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/personal-website_error.log
    CustomLog ${APACHE_LOG_DIR}/personal-website_access.log combined
</VirtualHost>
```

Aktifkan konfigurasi:
```bash
sudo a2ensite personal-website.conf
sudo a2enmod rewrite
sudo systemctl reload apache2
```

## Cara Kerja CI/CD

### Trigger Otomatis

Workflow akan otomatis berjalan ketika:
- Ada push ke branch `main` atau `master`
- Workflow di-trigger manual melalui GitHub Actions tab

### Proses Deployment

1. **Checkout Code**: Mengambil kode dari repository
2. **Setup SSH**: Mengkonfigurasi SSH connection menggunakan secrets
3. **Backup**: Membuat backup file yang sudah ada (jika ada)
4. **Deploy**: Mengunggah file ke server menggunakan rsync
5. **Verify**: Memverifikasi bahwa deployment berhasil
6. **Cleanup**: Membersihkan file temporary

### Monitoring Deployment

Anda bisa melihat status deployment di:
- **GitHub Repository** → **Actions** tab
- Setiap deployment akan menampilkan log lengkap

## Manual Deployment (Alternatif)

Jika Anda ingin melakukan deployment manual tanpa GitHub Actions:

### Menggunakan Script deploy.sh

1. Buat file `.env`:
   ```bash
   SERVER_IP=your_server_ip
   SSH_USER=your_ssh_user
   DEPLOY_PATH=/var/www/html
   SSH_PRIVATE_KEY="$(cat ~/.ssh/github_deploy_key)"
   ```

2. Jalankan script:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

### Menggunakan rsync langsung

```bash
rsync -avz --delete \
  -e "ssh -i ~/.ssh/your_key" \
  --exclude='.git' \
  --exclude='node_modules' \
  ./ user@server_ip:/var/www/html/personal-website/
```

## Troubleshooting

### Error: Permission Denied

**Penyebab**: SSH user tidak memiliki permission untuk membuat/menulis di direktori deployment.

**Solusi Lengkap**:

1. **Pastikan DEPLOY_PATH benar dan ada:**
   ```bash
   # Contoh DEPLOY_PATH yang benar:
   # /var/www/html
   # /home/user/www
   # /opt/websites
   
   # Jangan gunakan:
   # / (root directory)
   # /personal-website (tanpa parent directory)
   ```

2. **Buat direktori deployment di server (jika belum ada):**
   ```bash
   # Login ke server
   ssh user@server_ip
   
   # Buat direktori (ganti dengan DEPLOY_PATH Anda)
   sudo mkdir -p /var/www/html/personal-website
   sudo mkdir -p /var/www/html/personal-website/backup
   ```

3. **Set ownership dan permission:**
   ```bash
   # Ganti SSH_USER dengan username yang digunakan di GitHub Secrets
   # Ganti path dengan DEPLOY_PATH Anda
   sudo chown -R $SSH_USER:$SSH_USER /var/www/html/personal-website
   sudo chmod -R 755 /var/www/html/personal-website
   ```

4. **Atau jika menggunakan direktori di home user:**
   ```bash
   # Gunakan direktori di home user (tidak perlu sudo)
   mkdir -p ~/www/personal-website
   mkdir -p ~/www/personal-website/backup
   
   # Set DEPLOY_PATH di GitHub Secrets menjadi:
   # /home/username/www (ganti username dengan SSH_USER Anda)
   ```

5. **Verifikasi permission:**
   ```bash
   # Test apakah user bisa menulis
   touch /var/www/html/personal-website/test.txt
   rm /var/www/html/personal-website/test.txt
   
   # Jika error, berarti permission belum benar
   ```

**Catatan Penting**:
- Jika menggunakan `/var/www/html`, biasanya memerlukan `sudo` atau user harus dalam group `www-data`
- Lebih mudah menggunakan direktori di home user: `~/www` atau `/home/user/www`
- Pastikan DEPLOY_PATH di GitHub Secrets sesuai dengan path yang dibuat di server

### Error: Host Key Verification Failed

**Solusi**: Workflow sudah menangani ini dengan `StrictHostKeyChecking=no`, tapi jika masih error, pastikan server IP benar

### Error: Connection Timeout

**Solusi**: 
- Pastikan server IP benar dan accessible
- Check firewall settings di server
- Pastikan SSH port (22) terbuka

### File tidak muncul di website

**Solusi**:
- Check direktori deployment path sudah benar
- Pastikan web server dikonfigurasi untuk serve dari direktori yang benar
- Check permission file: `ls -la /var/www/html/personal-website/`
- Restart web server: `sudo systemctl restart nginx` atau `sudo systemctl restart apache2`

## Keamanan

### Best Practices

1. **Gunakan SSH Key**: Jangan gunakan password untuk autentikasi SSH
2. **Restrict SSH Access**: Batasi akses SSH hanya dari IP tertentu jika memungkinkan
3. **Regular Updates**: Update server dan dependencies secara berkala
4. **Backup**: Backup otomatis dibuat setiap deployment, simpan backup penting
5. **Monitor Logs**: Pantau log deployment dan web server untuk aktivitas mencurigakan

### Rotasi SSH Key

Disarankan untuk merotasi SSH key secara berkala:
1. Generate key baru
2. Update public key di server
3. Update secret `SSH_PRIVATE_KEY` di GitHub
4. Test deployment
5. Hapus key lama

## Support

Jika mengalami masalah dengan deployment, check:
1. GitHub Actions logs untuk error details
2. Server logs: `/var/log/nginx/error.log` atau `/var/log/apache2/error.log`
3. SSH connection: Test manual dengan `ssh user@server_ip`

