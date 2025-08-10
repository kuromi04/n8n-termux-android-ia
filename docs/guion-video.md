# Guión del video (voz en off)

Intro:
- "¿Te imaginas tener tu propia IA trabajando para ti desde el celular… sin pagar nada?"
- "Soy el primero en Android en instalar n8n en Termux para automatizar TODO con IA."

Beneficios:
- Gratis, local, sin VPS ni membresías.

Pasos (visual):
1) pkg update -y && pkg upgrade -y
2) pkg install -y nodejs-lts python binutils make clang pkg-config libsqlite ndk-sysroot
3) export GYP_DEFINES="android_ndk_path=''"
4) npm install -g n8n --sqlite=/data/data/com.termux/files/usr/bin/sqlite3
5) npm install -g pm2
6) pm2 start n8n && pm2 save
7) echo "\npm2 resurrect" >> ~/.bashrc
8) ifconfig -> abrir http://IP:5678

Cierre:
- "IA en tu Android, control total y cero gastos."
- "Suscríbete y comenta tus flujos de automatización." 
