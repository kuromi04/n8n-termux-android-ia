# n8n on Termux (Android) with AI — FREE, no VPS, no memberships

Run **n8n** directly on your **Android** device using **Termux** and **PM2**.  
Fully *local*, **free**, avoiding VPS costs or platform subscriptions.

> ⚡️ Note: According to the author, this is the **first** public installation of n8n on Android via Termux.

## 🚀 Features
- **Reproducible scripts** for installation and PM2 startup
- Video script + `.srt` subtitles
- Security & persistence guidelines
- `.gitignore` and MIT license

---

## 📋 Requirements
- Android 8+ (10+ recommended)
- [Termux](https://termux.dev) (from F-Droid or official repo)
- At least **3 GB** free space
- Local network if you want to access n8n from another device

---

## 🧰 Quick Installation (copy/paste in Termux)

### 1) Clone and enter the project (optional)
```bash
pkg update -y && pkg upgrade -y
pkg install -y git
git clone https://github.com/kuromi04/n8n-termux-android-ia.git
cd n8n-termux-android-ia
```

### 2) Run installer
```bash
chmod +x scripts/install_n8n_termux.sh
./scripts/install_n8n_termux.sh
```

### 3) Start n8n with PM2
```bash
chmod +x scripts/start_n8n_pm2.sh
./scripts/start_n8n_pm2.sh
```

### 4) Auto-start on Termux launch
Installer already appends a line to `~/.bashrc` for PM2 **resurrect**. To check:
```bash
tail -n 5 ~/.bashrc
```

### 5) Access from browser
Find your local IP and open `http://IP:5678`:
```bash
ifconfig
```

---

## 🛡️ Basic Security
- Use environment variables for credentials (never commit real `.env`).
- If exposing port 5678 outside your LAN, use **reverse proxy** with auth (e.g., Caddy/Traefik/Nginx).
- Consider **temporary tunnels** (ngrok/cloudflared) for testing.

---

## 🔧 Useful Environment Variables
In `~/.n8n/.env`:
```ini
N8N_PORT=5678
BASIC_AUTH_USER=admin
BASIC_AUTH_PASSWORD=change_this
N8N_USER_FOLDER=$HOME/.n8n
NODE_ENV=production
```

---

## 🧪 Quick check
```bash
pm2 list
pm2 logs n8n --lines 50
curl -I http://127.0.0.1:5678
```

---

## 🧯 Troubleshooting
- **Compilation error**: Reinstall `ndk-sysroot`, ensure `clang`, `make`, `python` are present.
- **SQLite missing**: Check path `--sqlite=/data/data/com.termux/files/usr/bin/sqlite3`.
- **PM2 not resurrecting**: Ensure `~/.bashrc` has `pm2 resurrect` and run `pm2 save`.
- **Cannot open in browser**: Check IP, router firewall, and port `5678` LAN accessibility.

---

## 🧾 Credits
- Author: @tiendastelegram
- Inspired by the n8n & Termux community

## 📄 License
[MIT](LICENSE)
