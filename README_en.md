# n8n on Termux (Android) with AI — FREE, no VPS, no subscriptions

Run **n8n** automation *locally* on your **Android** using **Termux** and **PM2**. 
Keep everything on your phone, save money, and avoid platforms/VPS fees.

> ⚡️ This repo accompanies a short video. According to the author, this is the **first** public n8n install on Android via Termux.

## 🚀 What you get
- Reproducible **install/start scripts**
- Video script + `.srt` subtitles
- **Backup/Restore scripts** for n8n data
- `.gitignore` and MIT license

---

## 📋 Requirements
- Android 8+ (10+ recommended)
- [Termux](https://termux.dev) (F-Droid or official repo)
- ~3 GB free space
- LAN access to reach n8n (optional)

---

## 🧰 Quick install

```bash
pkg update -y && pkg upgrade -y
pkg install -y git
git clone https://github.com/kuromi04/n8n-termux-android-ia.git
cd n8n-termux-android-ia

chmod +x scripts/*.sh
./scripts/install_n8n_termux.sh
./scripts/start_n8n_pm2.sh
```

Open from your browser on the same device or LAN:
```bash
ifconfig  # find your IP
# then navigate to http://IP:5678
```

---

## 🔐 Backups

By default, n8n data lives in `$HOME/.n8n`. Use the provided scripts:

### Create a backup (timestamped `.tar.gz` under `backups/`):
```bash
./scripts/backup_n8n.sh
```

### Restore from a backup:
```bash
./scripts/restore_n8n.sh backups/n8n-backup-YYYYmmdd-HHMMSS.tar.gz
```

> PM2 tips:
```bash
pm2 list
pm2 logs n8n --lines 50
pm2 save && pm2 resurrect
```

---

## 🛡️ Security
- Never commit real secrets. Prefer env vars in `$HOME/.n8n/.env`.
- If exposing 5678 outside LAN, use a reverse proxy with auth.
- Prefer temporary tunnels for demos, not production.

---

## 📄 License
[MIT](LICENSE)
