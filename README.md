# Personal Website - Agus Barlianto

Website personal modern dan responsif untuk Agus Barlianto. Dibangun dengan HTML, CSS, dan JavaScript vanilla.

## Fitur

- ✨ Desain modern dan menarik
- 📱 Fully responsive (mobile, tablet, desktop)
- 🎨 UI/UX yang user-friendly
- ⚡ Performa cepat dan ringan
- 🔍 SEO-friendly
- 🎯 Smooth scrolling navigation
- 📧 Contact form yang fungsional

## Struktur Proyek

```
personal-website/
│
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions CI/CD workflow
├── index.html              # Halaman utama
├── styles.css              # Styling dan layout
├── script.js               # JavaScript untuk interaktivitas
├── package.json            # Konfigurasi Node.js
├── deploy.sh               # Script untuk manual deployment
├── README.md               # Dokumentasi proyek
└── DEPLOYMENT.md           # Panduan deployment lengkap
```

## Bagian Website

1. **Hero Section** - Pengenalan dengan call-to-action
2. **About Section** - Informasi tentang Agus Barlianto
3. **Skills Section** - Keahlian dan kemampuan
4. **Projects Section** - Portfolio proyek terbaru
5. **Contact Section** - Form kontak dan informasi

## Cara Menggunakan

### Instalasi Dependencies

Pertama, install dependencies yang diperlukan:

```bash
npm install
```

### Menjalankan Server Development

Untuk menjalankan website di **localhost:3030**, gunakan perintah berikut:

```bash
npm start
```

atau

```bash
npm run dev
```

Server akan otomatis membuka browser di `http://localhost:3030`

### Alternatif Lain

Jika tidak menggunakan npm, Anda juga bisa:

1. **Buka langsung**: Buka file `index.html` di browser web Anda
2. **Menggunakan Python**:
   ```bash
   python -m http.server 3030
   ```
3. **Menggunakan http-server langsung**:
   ```bash
   npx http-server -p 3030 -o
   ```

## Kustomisasi

### Mengubah Informasi Personal

1. **Nama dan Tagline**: Edit di bagian Hero Section (`index.html`)
2. **About Section**: Update konten tentang di section `#about`
3. **Skills**: Tambah atau edit skill cards di section `#skills`
4. **Projects**: Update proyek-proyek di section `#projects`
5. **Contact Info**: Ubah informasi kontak di section `#contact`

### Mengubah Warna

Edit variabel CSS di file `styles.css`:

```css
:root {
    --primary-color: #4f46e5;      /* Warna utama */
    --primary-dark: #4338ca;       /* Warna utama gelap */
    --secondary-color: #6366f1;    /* Warna sekunder */
    /* ... variabel lainnya */
}
```

### Menambahkan Proyek Baru

Tambahkan card baru di section projects:

```html
<div class="project-card">
    <div class="project-image">
        <div class="project-placeholder">Nama Proyek</div>
    </div>
    <div class="project-content">
        <h3>Judul Proyek</h3>
        <p>Deskripsi proyek</p>
        <div class="project-tags">
            <span class="tag">Teknologi 1</span>
            <span class="tag">Teknologi 2</span>
        </div>
    </div>
</div>
```

## Browser Support

Website ini kompatibel dengan browser modern:
- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## CI/CD Deployment

Website ini dilengkapi dengan GitHub Actions untuk deployment otomatis ke server.

### Setup GitHub Secrets

Untuk mengaktifkan CI/CD, Anda perlu mengatur secrets berikut di GitHub repository:

1. **SERVER_IP** - IP address atau hostname server
2. **SSH_USER** - Username untuk SSH login
3. **SSH_PRIVATE_KEY** - Private SSH key untuk autentikasi
4. **DEPLOY_PATH** - Path direktori deployment di server (contoh: `/var/www/html`)

### Cara Setup

1. Buka repository GitHub → **Settings** → **Secrets and variables** → **Actions**
2. Klik **New repository secret** dan tambahkan setiap secret di atas
3. Push ke branch `main` atau `master` untuk trigger deployment otomatis

**📖 Untuk panduan lengkap, lihat [DEPLOYMENT.md](DEPLOYMENT.md)**

### Manual Deployment

Jika ingin melakukan deployment manual:

```bash
# Setup environment variables
export SERVER_IP=your_server_ip
export SSH_USER=your_ssh_user
export DEPLOY_PATH=/var/www/html
export SSH_PRIVATE_KEY="$(cat ~/.ssh/your_key)"

# Run deployment script
chmod +x deploy.sh
./deploy.sh
```

## Teknologi yang Digunakan

- HTML5
- CSS3 (dengan CSS Variables dan Grid/Flexbox)
- JavaScript (Vanilla JS)
- Google Fonts (Inter)
- GitHub Actions (CI/CD)

## Lisensi

Proyek ini bebas digunakan untuk keperluan personal atau komersial.

## Kontak

Untuk pertanyaan atau kolaborasi, silakan hubungi melalui form kontak di website atau email: agus.barlianto@email.com

---

Dibuat dengan ❤️ untuk Agus Barlianto

