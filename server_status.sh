#!/usr/bin/env bash
#
# server_status.sh
# -----------------------------------------------------------------------------
# Purpose:
#   Collects key health metrics from this Ubuntu / DigitalOcean server and
#   generates a styled HTML status page that is served by nginx. The output is
#   therefore publicly verifiable online at:
#       https://substanceinfo.xyz/status.html
#   This lets anyone (e.g. a marker) confirm the script's output without
#   needing SSH access to the server.
#
# Author : Student 35984197 (ICT171)
# Usage  : sudo ./server_status.sh
# Cron   : */30 * * * * /root/server_status.sh   # refresh every 30 minutes
# -----------------------------------------------------------------------------

set -euo pipefail   # stop on errors, undefined vars, and broken pipes

# --- Configuration -----------------------------------------------------------
OUTPUT="/var/www/stayaware/status.html"          # where the page is written
DOMAIN="substanceinfo.xyz"                        # used to read the SSL cert
CERT="/etc/letsencrypt/live/${DOMAIN}/cert.pem"   # Let's Encrypt certificate

# --- Collect metrics ---------------------------------------------------------
GENERATED="$(date '+%Y-%m-%d %H:%M:%S %Z')"       # when this report was made
HOSTNAME_VAL="$(hostname)"                         # server hostname
KERNEL="$(uname -r)"                               # kernel version
UPTIME_VAL="$(uptime -p)"                          # human-readable uptime

# Disk usage of the root filesystem: used / total / percentage
DISK="$(df -h --output=used,size,pcent / | tail -n 1 | tr -s ' ')"

# Memory: used / total
MEM="$(free -h | awk '/^Mem:/ {print $3 " / " $2}')"

# Is the nginx service running? (active / inactive / failed)
NGINX_STATUS="$(systemctl is-active nginx || true)"

# SSL certificate expiry date, read straight from the certificate file
if [[ -r "$CERT" ]]; then
  SSL_EXPIRY="$(openssl x509 -enddate -noout -in "$CERT" | cut -d= -f2)"
else
  SSL_EXPIRY="certificate not readable (run the script with sudo)"
fi

# --- Generate the HTML page --------------------------------------------------
cat > "$OUTPUT" <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Server Status — SubstanceInfo</title>
  <link rel="stylesheet" href="style.css">
  <style>
    .status-wrap { max-width: 760px; margin: 60px auto; padding: 0 20px; }
    .status-card { border: 1px solid #ddd; border-radius: 12px; padding: 28px; }
    .status-row  { display: flex; justify-content: space-between;
                   padding: 12px 0; border-bottom: 1px solid #eee; }
    .status-row:last-child { border-bottom: none; }
    .ok    { color: #1a7f37; font-weight: 600; }
    .label { color: #555; }
  </style>
</head>
<body>
  <div class="status-wrap">
    <h1>Server Status</h1>
    <p class="label">
      Live health report for ${DOMAIN}, generated automatically by
      <code>server_status.sh</code>.
    </p>
    <div class="status-card">
      <div class="status-row"><span class="label">Generated</span><span>${GENERATED}</span></div>
      <div class="status-row"><span class="label">Hostname</span><span>${HOSTNAME_VAL}</span></div>
      <div class="status-row"><span class="label">Kernel</span><span>${KERNEL}</span></div>
      <div class="status-row"><span class="label">Uptime</span><span>${UPTIME_VAL}</span></div>
      <div class="status-row"><span class="label">Disk (used / total / %)</span><span>${DISK}</span></div>
      <div class="status-row"><span class="label">Memory (used / total)</span><span>${MEM}</span></div>
      <div class="status-row"><span class="label">Web server (nginx)</span><span class="ok">${NGINX_STATUS}</span></div>
      <div class="status-row"><span class="label">SSL certificate expires</span><span>${SSL_EXPIRY}</span></div>
    </div>
  </div>
</body>
</html>
HTML

# --- Confirmation to the operator -------------------------------------------
echo "Status page written to ${OUTPUT}"
echo "View it online at: https://${DOMAIN}/status.html"
