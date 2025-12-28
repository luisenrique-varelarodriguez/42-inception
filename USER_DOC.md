# 📖 User Documentation

This document explains how to use the Inception project from an end-user perspective.

## 📦 Provided Services

The infrastructure provides mandatory and bonus services:

### Mandatory Services

### 1. NGINX Web Server
- **Purpose:** Web server and reverse proxy
- **Port:** 443 (HTTPS only)
- **Features:** 
  - TLSv1.2/TLSv1.3 encryption
  - Self-signed SSL certificate
  - Serves static files and proxies PHP requests to WordPress

### 2. WordPress CMS
- **Purpose:** Content management system
- **Port:** 9000 (internal, PHP-FPM)
- **Features:**
  - Complete WordPress installation
  - Two user accounts (admin + author)
  - Automated setup and configuration
  - Persistent data storage
  - Redis object caching enabled

### 3. MariaDB Database
- **Purpose:** Relational database
- **Port:** 3306 (internal only)
- **Features:**
  - WordPress database storage
  - Automated initialization
  - Persistent data storage
  - Secure user configuration

### Bonus Services

### 4. Adminer
- **Purpose:** Database management tool
- **Port:** 8080 (HTTP)
- **URL:** http://localhost:8080
- **Features:**
  - Web interface for MariaDB
  - Execute SQL queries
  - Import/export data
  - View and edit tables

### 5. Redis Cache
- **Purpose:** Object cache for WordPress
- **Port:** 6379 (internal)
- **Features:**
  - In-memory caching
  - Accelerates WordPress
  - Reduces database load

### 6. Static Website
- **Purpose:** HTML/CSS/JS static site
- **Port:** 8081 (HTTP)
- **URL:** http://localhost:8081
- **Features:**
  - Pure static content
  - No PHP required
  - Fast and lightweight

### 7. FTP Server
- **Purpose:** File transfer to WordPress
- **Port:** 21, 21100-21110
- **Features:**
  - Upload/download WordPress files
  - Direct volume access
  - Secure authentication

## 🚀 Starting the Project

### First-Time Setup

1. **Configure your domain:**
   ```bash
   sudo nano /etc/hosts
   ```
   Add this line (replace `cx02923` with your 42 login):
   ```
   127.0.0.1 cx02923.42.fr
   ```

2. **Configure environment variables:**
   ```bash
   nano srcs/.env
   ```
   Update at least:
   - `DOMAIN_NAME` (your-login.42.fr)
   - `LOGIN` (your 42 login)
   - All passwords (use strong passwords)
   - `WP_ADMIN_USER` (cannot be "admin" or "administrator")

3. **Start all services:**
   ```bash
   make
   ```
   Or:
   ```bash
   docker compose -f srcs/docker-compose.yml up -d --build
   ```

4. **Wait for services to initialize:**
   - First startup takes 30-60 seconds
   - Health checks ensure proper startup order
   - Check status: `make ps` or `docker compose -f srcs/docker-compose.yml ps`

## 🛑 Stopping the Project

### Stop Services (Keep Data)
```bash
make down
```
Or:
```bash
docker compose -f srcs/docker-compose.yml down
```

This stops and removes containers but preserves your data in `~/data/`.

### Stop Without Removing Containers
```bash
make stop
```

This simply stops the containers without removing them.

## 🌐 Accessing the Website

### Main Website
Open your browser and navigate to:
```
https://cx02923.42.fr
```
(Replace `cx02923` with your login)

**Note:** You'll see a security warning because the SSL certificate is self-signed. This is expected. Click "Advanced" → "Proceed to site" (or equivalent in your browser).

### WordPress Admin Panel
Access the administration interface at:
```
https://cx02923.42.fr/wp-admin
```

Log in with the credentials you set in `.env`:
- **Username:** Value of `WP_ADMIN_USER`
- **Password:** Value of `WP_ADMIN_PASS`

## 🔐 Managing Credentials

### Where Credentials Are Stored
All credentials are in `srcs/.env`. This file is **not** committed to Git.

### Available Credentials

**WordPress Admin User:**
- Username: `WP_ADMIN_USER` in .env
- Password: `WP_ADMIN_PASS` in .env
- Role: Administrator (full access)

**WordPress Additional User:**
- Username: `WORDPRESS_USER` in .env
- Password: `WORDPRESS_USER_PASSWORD` in .env
- Email: `WORDPRESS_USER_EMAIL` in .env
- Role: Author (can create/edit own posts)

**MariaDB Root:**
- Username: `root`
- Password: `MYSQL_ROOT_PASSWORD` in .env
- Access: Internal only (not exposed to host)

**MariaDB WordPress User:**
- Username: `MYSQL_USER` in .env
- Password: `MYSQL_USER_PASSWORD` in .env
- Database: `MYSQL_DATABASE` in .env
- Access: Internal only

### Changing Credentials

⚠️ **Warning:** Changing credentials after first startup requires data cleanup.

1. Stop the project:
   ```bash
   make down
   ```

2. Clean existing data:
   ```bash
   make clean
   ```

3. Edit credentials:
   ```bash
   nano srcs/.env
   ```

4. Restart:
   ```bash
   make
   ```

## 📊 Checking Service Status

### View All Services
```bash
make ps
```
Or:
```bash
docker compose -f srcs/docker-compose.yml ps
```

**Healthy output example:**
```
NAME        IMAGE         STATUS                    PORTS
mariadb     mariadb       Up 2 minutes (healthy)
wordpress   wordpress     Up 2 minutes (healthy)
nginx       nginx         Up 2 minutes (healthy)    0.0.0.0:443->443/tcp
```

All services should show `(healthy)` status.

### View Service Logs

**All services:**
```bash
make logs
```

**Specific service:**
```bash
docker compose -f srcs/docker-compose.yml logs -f [service_name]
```

Examples:
```bash
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb
```

**Tip:** Press `Ctrl+C` to stop following logs.

### Check Health Status

```bash
docker inspect mariadb --format='{{.State.Health.Status}}'
docker inspect wordpress --format='{{.State.Health.Status}}'
docker inspect nginx --format='{{.State.Health.Status}}'
```

Should all return: `healthy`

## 🔧 Common Operations

### Restart All Services
```bash
make restart
```

### Restart Specific Service
```bash
docker compose -f srcs/docker-compose.yml restart [service_name]
```

### Execute Command in Container
```bash
docker exec -it [container_name] bash
```

Examples:
```bash
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
```

### View WordPress Files
```bash
ls -la ~/data/wordpress/
```

### View Database Files
```bash
ls -la ~/data/mariadb/
```

## 🆘 Troubleshooting

### Can't Access Website (502 Bad Gateway)

**Cause:** WordPress or MariaDB not fully started.

**Solution:**
```bash
# Check logs
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb

# Wait 30-60 seconds for initialization
# Check health status
make ps
```

### Can't Access Website (403 Forbidden)

**Cause:** WordPress files not properly initialized.

**Solution:**
```bash
# Check WordPress container logs
docker compose -f srcs/docker-compose.yml logs wordpress

# Verify WordPress files exist
docker exec wordpress ls -la /var/www/html/

# Restart if needed
make restart
```

### Port 443 Already in Use

**Cause:** Another service using port 443.

**Solution:**
```bash
# Find the process
sudo lsof -i :443

# Stop it or change its port
# Then restart Inception
make down
make
```

### Service Unhealthy

**Cause:** Health check failing.

**Solution:**
```bash
# Check specific service logs
docker compose -f srcs/docker-compose.yml logs [service_name]

# Try restarting
docker compose -f srcs/docker-compose.yml restart [service_name]

# If persistent, rebuild
make fclean
make
```

### Lost Admin Password

**Solution:**
1. Stop project: `make down`
2. Clean data: `make clean`
3. Update password in `srcs/.env`
4. Restart: `make`

### Permission Denied Errors

**Solution:**
```bash
# Ensure data directories exist with correct permissions
mkdir -p ~/data/mariadb ~/data/wordpress
chmod -R 755 ~/data/
```

## 📋 Quick Reference

| Command | Action |
|---------|--------|
| `make` | Build and start all services |
| `make down` | Stop and remove containers |
| `make stop` | Stop containers without removing |
| `make restart` | Restart all services |
| `make logs` | View logs (follow mode) |
| `make ps` | Show service status |
| `make clean` | Remove data (keeps images) |
| `make fclean` | Remove everything |

| URL | Purpose |
|-----|---------|
| `https://cx02923.42.fr` | Main website |
| `https://cx02923.42.fr/wp-admin` | Admin panel |
| `http://localhost:8080` | Adminer (database) |
| `http://localhost:8081` | Static website |
| `ftp://localhost:21` | FTP server |

| Location | Content |
|----------|---------|
| `srcs/.env` | Configuration and credentials |
| `~/data/wordpress/` | WordPress files |
| `~/data/mariadb/` | Database files |

## 🎁 Using Bonus Services

### Adminer - Database Management

**Access:** http://localhost:8080

**Login:**
- System: MySQL
- Server: mariadb
- Username: (your `MYSQL_USER`)
- Password: (your `MYSQL_USER_PASSWORD`)
- Database: (your `MYSQL_DATABASE`)

**What you can do:**
- Browse all database tables
- Execute SQL queries directly
- View WordPress data structure
- Export database backups
- Import data

### Redis Cache - Performance Monitoring

**Check Redis status:**
```bash
# Verify Redis is running
docker exec redis redis-cli ping
# Should return: PONG

# View cache statistics
docker exec redis redis-cli INFO stats

# See cached keys
docker exec redis redis-cli KEYS *
```

**In WordPress:**
1. Go to WordPress Admin
2. Settings → Redis
3. View connection status and cache statistics
4. See cache hits/misses ratio

### Static Website

**Access:** http://localhost:8081

A demonstration static HTML site showing that NGINX can serve pure static content without PHP.

**Customization:**
Edit `/Users/cx02923/Desktop/42/42-inception/srcs/requirements/bonus/website/conf/index.html` to customize content.

### FTP Server - File Management

**Connect with terminal:**
```bash
# Basic FTP
ftp localhost
# Username: ftpuser (or your FTP_USER)
# Password: ftppass123 (or your FTP_PASS)

# Or with lftp (better)
lftp -u ftpuser,ftppass123 localhost
ls
cd wp-content/uploads
put myfile.jpg
get existingfile.jpg
quit
```

**Connect with FileZilla:**
1. Open FileZilla
2. Host: localhost
3. Username: (your `FTP_USER`)
4. Password: (your `FTP_PASS`)
5. Port: 21
6. Connect

**What you can do:**
- Upload media files to WordPress
- Download backups
- Edit theme files (be careful!)
- Manage plugins
- Access all WordPress directories

**FTP Directory Structure:**
```
/ (WordPress root)
├── wp-admin/
├── wp-content/
│   ├── themes/
│   ├── plugins/
│   └── uploads/
├── wp-includes/
└── wp-config.php
```

## 💡 Tips

- Always check `make ps` to verify all services are healthy
- Give the stack 30-60 seconds to fully initialize on first start
- Use `make logs` to troubleshoot any issues
- Keep your `.env` file secure and never commit it to Git
- The self-signed SSL certificate warning is expected and safe to bypass for local development
