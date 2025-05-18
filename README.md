# 🎯 Cam Hacker - Advanced Multi-Payload Phishing Tool

> **Educational Red Team project** that captures victim webcam photos, IP address, geolocation, and sends everything directly to Telegram — silently.

## 🔥 Features

- 🎥 **Webcam Capture** (via `getUserMedia`)
- 🌐 **IP + GeoLocation** logging
- 🕒 **Timestamping**
- 📬 **Exfiltration via Telegram**
- 🛡 **Cloudflare Tunnel** (HTTPS + 🔒 Padlock)
- 🤐 **No terminal output** — fully silent

## 🧠 How It Works

1. Attacker runs `launch.sh`
2. Chooses phishing page (e.g., Google Meet Cam)
3. Cloudflared exposes it via a public HTTPS URL
4. Victim opens the link → camera accessed → IP + geo logged
5. Bot sends all data + webcam photo to Telegram silently

## 🚀 Setup & Usage

### 1. Install Cloudflared

```bash
sudo apt install cloudflared
```

### 2. Run the Tool

```bash
bash launch.sh
```

### 3. Send Link to Victim

Once the public URL appears, send it to your controlled target.

## 🔒 Disclaimer

This tool is for **educational and authorized testing only**.  
**Do not use** against targets you do not have permission to test.

---

🧑‍💻 Built for Red Team practice by Athul M  
