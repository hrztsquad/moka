#!/usr/bin/env bash
set -euo pipefail

echo "=== Moka POS Bar - VPS Production Deploy ==="

# 1. Ensure Docker & Docker Compose are installed
if ! command -v docker >/dev/null 2>&1; then
  echo "[1/5] Installing Docker..."
  curl -fsSL https://get.docker.com | sh
  systemctl enable --now docker || true
else
  echo "[1/5] Docker already installed."
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "Installing docker-compose-plugin..."
  apt-get update -y && apt-get install -y docker-compose-plugin
fi

# 2. Prepare .env if missing
if [ ! -f .env ]; then
  echo "[2/5] Creating .env from .env.example..."
  cp .env.example .env

  # Generate strong random AUTH_SECRET and DB password
  AUTH_SECRET=$(openssl rand -hex 32)
  DB_PASS=$(openssl rand -hex 16)

  sed -i "s|^AUTH_SECRET=.*|AUTH_SECRET=\"${AUTH_SECRET}\"|" .env
  sed -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=${DB_PASS}|" .env
  sed -i "s|^DATABASE_URL=.*|DATABASE_URL=\"postgresql://postgres:${DB_PASS}@postgres:5432/moka_pos_bar?schema=public\"|" .env

  if [ -t 0 ]; then
    read -rp "Username / Email Admin Anda [admin]: " INPUT_EMAIL
    read -rp "Nama Admin Anda [Admin]: " INPUT_NAME
    read -rsp "Password Admin Anda [admin]: " INPUT_PASS
    echo ""
    read -rp "Port aplikasi [3000]: " INPUT_PORT

    ADMIN_EMAIL=${INPUT_EMAIL:-admin}
    ADMIN_NAME=${INPUT_NAME:-Admin}
    ADMIN_PASSWORD=${INPUT_PASS:-admin}
    APP_PORT=${INPUT_PORT:-3000}

    sed -i "s|^ADMIN_EMAIL=.*|ADMIN_EMAIL=\"${ADMIN_EMAIL}\"|" .env
    sed -i "s|^ADMIN_NAME=.*|ADMIN_NAME=\"${ADMIN_NAME}\"|" .env
    sed -i "s|^ADMIN_PASSWORD=.*|ADMIN_PASSWORD=\"${ADMIN_PASSWORD}\"|" .env
    sed -i "s|^APP_PORT=.*|APP_PORT=${APP_PORT}|" .env
  fi
else
  echo "[2/5] Using existing .env..."
fi

# Load .env for display
set -a
# shellcheck disable=SC1091
source .env
set +a

# 3. Build and start containers
echo "[3/5] Building & starting Docker containers..."
docker compose -f docker-compose.prod.yml up -d --build

# 4. Run database migrations & seeders
echo "[4/5] Running Prisma migrations & seed..."
docker compose -f docker-compose.prod.yml exec -T app npx prisma migrate deploy
docker compose -f docker-compose.prod.yml exec -T app npx prisma db seed

# 5. Summary
SERVER_IP=$(curl -fsSL https://ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
echo ""
echo "[5/5] Deployment selesai!"
echo "============================================"
echo "URL Aplikasi : http://${SERVER_IP}:${APP_PORT:-3000}"
echo "Login Admin  : ${ADMIN_EMAIL:-admin}"
echo "Password     : (sesuai yang Anda masukkan / default di .env)"
echo "Demo Kasir   : kasir@coffeeshop.test / password"
echo "============================================"
echo "Catatan: Jika memakai domain + HTTPS (Nginx/Caddy), ubah COOKIE_SECURE=true di .env lalu restart:"
echo "  docker compose -f docker-compose.prod.yml up -d"
