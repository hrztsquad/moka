# Moka POS Bar
**A fast, role-based POS built for high-pressure bar operations.**

Moka POS Bar is designed to keep service moving when your floor is busy, your queue is long, and speed is non-negotiable. It gives cashiers, waiters, and managers a focused workflow with clear responsibilities, accurate order handling, and real-time operational control.

## Why Teams Choose Moka POS Bar
- **Built for speed:** Checkout and order flows are optimized for fast actions and minimal friction.
- **Role-specific experience:** Cashier, waiter, and admin views are separated by responsibility to reduce mistakes.
- **Operational clarity:** Inventory, payment handling, and order status stay visible and structured during peak hours.
- **Consistent execution:** The UI and flow are crafted to feel predictable, so staff can move confidently under pressure.
- **Management visibility:** Reporting and oversight features help owners and managers make faster decisions.

## What It Solves
- Slow checkout during busy periods
- Miscommunication between waiter and cashier
- Inconsistent order handling across shifts
- Poor visibility into product, payment, and performance trends

## Business Value
Moka POS Bar helps teams serve faster, reduce operational errors, and maintain a clean service rhythm from order intake to final payment. The result is a smoother guest experience and tighter daily control for your business.

## Product Direction
This project is focused on delivering a modern, production-ready POS experience with the reliability of a robust backend and the responsiveness of a contemporary web application stack.

## Deploy di VPS (Ubuntu / Debian)

1. Clone repository ini di VPS Anda:
   ```bash
   git clone https://github.com/hrztsquad/moka.git
   cd moka
   ```
2. Jalankan script instalasi otomatis:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```
   Script akan otomatis:
   - Menginstal Docker & Docker Compose (jika belum ada)
   - Membuat `.env` dengan `AUTH_SECRET` dan password database acak
   - Meminta input email, nama, dan password untuk akun Admin Anda (atau memakai default)
   - Menjalankan container PostgreSQL & Next.js (`docker-compose.prod.yml`)
   - Menjalankan migrasi database (`prisma migrate deploy`) dan seeder (`prisma db seed`)

3. Akses aplikasi melalui browser di `http://<IP-VPS-ANDA>:3000`.
   > Jika Anda memasang domain + HTTPS melalui Nginx/Caddy, ubah `COOKIE_SECURE=true` di `.env` lalu jalankan `docker compose -f docker-compose.prod.yml up -d`.

## Akun Login Default (Seeder)

- **Admin Khusus Anda** (dapat dikustomisasi lewat `.env` / saat menjalankan `./deploy.sh`):
  - Username / Email: `admin`
  - Password: `admin`
- **Akun Demo** (password semua akun demo: `password`):
  - Admin: `admin@coffeeshop.test`
  - Manager: `manager@coffeeshop.test`
  - Kasir: `kasir@coffeeshop.test`
  - Waiter 1: `waiter1@coffeeshop.test`
  - Waiter 2: `waiter2@coffeeshop.test`

