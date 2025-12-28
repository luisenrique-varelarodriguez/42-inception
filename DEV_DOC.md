# 🛠️ Developer Documentation

This document explains how to build, configure, and maintain the Inception project from a developer perspective.

## 🏗️ Setup From Scratch

### Prerequisites

Ensure you have the following installed:

```bash
# Check Docker version (20.10+)
docker --version

# Check Docker Compose version (2.0+)
docker compose version

# Check Make
make --version
```

### Initial Setup Steps

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd inception
   ```

2. **Create environment file:**
   ```bash
   cp srcs/.env.example srcs/.env
   nano srcs/.env
   ```

3. **Configure mandatory variables:**
   - `DOMAIN_NAME`: Your login.42.fr (e.g., `cx02923.42.fr`)
   - `LOGIN`: Your 42 login
   - `WP_ADMIN_USER`: Admin username (NOT "admin" or "administrator")
   - All passwords (use secure values)

4. **Add domain to hosts file:**
   ```bash
   sudo nano /etc/hosts
   ```
   Add:
   ```
   127.0.0.1 your-login.42.fr
   ```

5. **Create data directories:**
   ```bash
   mkdir -p ~/data/mariadb ~/data/wordpress
   ```

## 🚀 Build and Launch

### Using Makefile (Recommended)

The Makefile provides convenient commands for all operations:

#### Build and Start
```bash
make
# or explicitly
make up
```

This command:
- Creates data directories if they don't exist
- Builds all Docker images
- Starts containers in detached mode
- Applies health checks and dependencies

#### Other Makefile Commands

```bash
make down      # Stop and remove containers
make stop      # Stop containers (keep them)
make restart   # Restart all services
make logs      # Follow logs from all services
make ps        # Show container status
make clean     # Remove data directories content
make fclean    # Remove containers, images, volumes, and data
make destroy   # Nuclear option: remove ALL Docker resources
```

### Using Docker Compose Directly

```bash
# Build and start
docker compose -f srcs/docker-compose.yml up -d --build

# Stop and remove
docker compose -f srcs/docker-compose.yml down

# Stop only
docker compose -f srcs/docker-compose.yml stop

# View logs
docker compose -f srcs/docker-compose.yml logs -f

# Status
docker compose -f srcs/docker-compose.yml ps
```

## 🐳 Managing Containers

### View Running Containers
```bash
docker ps
# or
docker compose -f srcs/docker-compose.yml ps
```

### Execute Commands in Containers

```bash
# Start a shell
docker exec -it [container_name] bash

# Run specific command
docker exec [container_name] [command]

# Examples:
docker exec -it wordpress bash
docker exec mariadb mysql -u root -p
docker exec nginx nginx -t  # Test nginx config
```

### Inspect Container Details
```bash
# Full inspection
docker inspect [container_name]

# Specific information
docker inspect [container_name] --format='{{.State.Status}}'
docker inspect [container_name] --format='{{.State.Health.Status}}'
docker inspect [container_name] --format='{{.NetworkSettings.Networks}}'
```

### View Resource Usage
```bash
# Real-time stats
docker stats

# Specific container
docker stats [container_name]
```

### Container Logs
```bash
# Follow logs
docker logs -f [container_name]

# Last 100 lines
docker logs --tail 100 [container_name]

# With timestamps
docker logs -t [container_name]
```

## 💾 Managing Volumes

### Volume Structure

The project uses bind mounts to host directories:

```
~/data/
├── mariadb/          # MariaDB data files
│   ├── mysql/        # System database
│   ├── wordpress/    # WordPress database
│   └── ...
└── wordpress/        # WordPress application files
    ├── wp-content/   # Themes, plugins, uploads
    ├── wp-config.php # WordPress configuration
    └── ...
```

### Volume Operations

**List volumes:**
```bash
docker volume ls
```

**Inspect volume:**
```bash
docker volume inspect [volume_name]
```

**View bind mount content:**
```bash
ls -la ~/data/mariadb/
ls -la ~/data/wordpress/
```

**Backup volumes:**
```bash
# Backup WordPress
tar -czf wordpress-backup-$(date +%Y%m%d).tar.gz -C ~/data wordpress

# Backup MariaDB
tar -czf mariadb-backup-$(date +%Y%m%d).tar.gz -C ~/data mariadb
```

**Restore volumes:**
```bash
# Stop services first
make down

# Remove old data
rm -rf ~/data/wordpress/* ~/data/mariadb/*

# Extract backup
tar -xzf wordpress-backup-YYYYMMDD.tar.gz -C ~/data
tar -xzf mariadb-backup-YYYYMMDD.tar.gz -C ~/data

# Restart services
make
```

**Clean volumes:**
```bash
# Clean content but keep directories
make clean

# Remove everything
make fclean
```

## 🗄️ Data Persistence

### How Persistence Works

**MariaDB:**
- Data stored in `~/data/mariadb/`
- Mounted to `/var/lib/mysql` in container
- Initialization marker: `/var/lib/mysql/.initialized`
- Database persists across container restarts/rebuilds

**WordPress:**
- Files stored in `~/data/wordpress/`
- Mounted to `/var/www/html` in container
- Initialization marker: `/var/www/html/.initialized`
- Content persists across container restarts/rebuilds

### Persistence Strategy

**First Start:**
1. Directories are empty
2. MariaDB initializes database
3. WordPress downloads core files
4. WordPress configures wp-config.php
5. WordPress installs with provided credentials
6. Marker files created

**Subsequent Starts:**
1. Marker files detected
2. Initialization skipped
3. Services start with existing data
4. Data remains consistent

### Forcing Re-initialization

```bash
# Stop services
make down

# Remove data
make clean
# or manually:
rm -rf ~/data/mariadb/* ~/data/wordpress/*

# Restart (will re-initialize)
make
```

## 🏗️ Architecture Details

### Service Dependencies

```
mariadb (starts first)
  └── healthcheck: mysqladmin ping
       └── wordpress (starts when MariaDB is healthy)
            └── healthcheck: pidof php-fpm7.4
                 └── nginx (starts when WordPress is healthy)
                      └── healthcheck: curl https://localhost
```

### Network Configuration

- **Network name:** `inception`
- **Driver:** `bridge`
- **Containers:** All services on same network
- **DNS:** Container names resolve to IPs
- **Isolation:** Isolated from host and other Docker networks
- **External access:** Only port 443 exposed

### Service Communication

```
Host (port 443)
  ↓
nginx:443 (TLS termination)
  ↓
wordpress:9000 (FastCGI)
  ↓
mariadb:3306 (MySQL protocol)
```

## 🔧 Configuration Files

### Docker Compose (`srcs/docker-compose.yml`)

**Services configuration:**
- `build`: Context and Dockerfile location
- `depends_on`: Service dependencies with health conditions
- `volumes`: Bind mounts to host directories
- `networks`: Network attachment
- `restart`: Restart policy (`unless-stopped`)
- `healthcheck`: Health check configuration
- `env_file`: Environment variables source

**Volumes configuration:**
- `driver`: `local`
- `driver_opts`: Bind mount options
  - `type: none`
  - `o: bind`
  - `device`: Host path

**Networks configuration:**
- `name`: Network name
- `driver`: Bridge driver

### Environment Variables (`srcs/.env`)

**Domain:**
- `DOMAIN_NAME`: Your login.42.fr
- `LOGIN`: Your 42 login

**MariaDB:**
- `MYSQL_ROOT_PASSWORD`: Root password
- `MYSQL_DATABASE`: Database name
- `MYSQL_USER`: WordPress DB user
- `MYSQL_USER_PASSWORD`: WordPress DB password
- `DB_HOST`: Database host (service name)

**WordPress:**
- `PROJECT`: Site title
- `WP_ADMIN_USER`: Admin username (not admin/administrator)
- `WP_ADMIN_PASS`: Admin password
- `WORDPRESS_USER`: Additional user
- `WORDPRESS_USER_EMAIL`: Additional user email
- `WORDPRESS_USER_PASSWORD`: Additional user password

### Dockerfile Best Practices

**Used in this project:**
- ✅ Base image with version tag (no `latest`)
- ✅ Multi-line RUN with `&&` for layer optimization
- ✅ Cleanup in same layer (`apt-get clean`, `rm -rf /var/lib/apt/lists/*`)
- ✅ Minimal base images (`debian:bullseye-slim`)
- ✅ No passwords in Dockerfile (use ENV vars)
- ✅ ENTRYPOINT for initialization scripts
- ✅ EXPOSE for documentation
- ✅ Single process per container (no supervisord)

## 🔍 Debugging

### Check Service Health

```bash
# All services
docker compose -f srcs/docker-compose.yml ps

# Specific health status
docker inspect mariadb --format='{{json .State.Health}}' | jq
docker inspect wordpress --format='{{json .State.Health}}' | jq
docker inspect nginx --format='{{json .State.Health}}' | jq
```

### Test Database Connection

```bash
# From host
docker exec -it mariadb mysql -u wpuser -p -e "SHOW DATABASES;"

# From WordPress container
docker exec -it wordpress mysql -h mariadb -u wpuser -p -e "SHOW DATABASES;"
```

### Test NGINX Configuration

```bash
# Test syntax
docker exec nginx nginx -t

# Reload config
docker exec nginx nginx -s reload
```

### Test WordPress PHP

```bash
# Check PHP-FPM process
docker exec wordpress pidof php-fpm7.4

# Test PHP
docker exec wordpress php -v
docker exec wordpress php -m  # List modules
```

### View Service Startup

```bash
# Watch logs in real-time
docker compose -f srcs/docker-compose.yml logs -f

# Specific service
docker compose -f srcs/docker-compose.yml logs -f mariadb
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f nginx
```

### Network Troubleshooting

```bash
# List networks
docker network ls

# Inspect network
docker network inspect inception

# Test connectivity from WordPress
docker exec wordpress ping -c 3 mariadb
docker exec wordpress nc -zv mariadb 3306

# Test connectivity from NGINX
docker exec nginx ping -c 3 wordpress
docker exec nginx nc -zv wordpress 9000
```

## 🔐 Security Considerations

### Current Implementation

**Environment Variables:**
- Stored in `srcs/.env` (gitignored)
- Loaded via `env_file` in docker-compose.yml
- Visible in `docker inspect`

**Network Isolation:**
- Custom bridge network
- Services isolated from host network
- Only port 443 exposed

**SSL/TLS:**
- Self-signed certificate (development)
- TLSv1.2 and TLSv1.3 only
- Generated at runtime if missing

### Production Improvements

For production deployment, consider:

1. **Docker Secrets:**
   ```yaml
   secrets:
     db_password:
       file: ./secrets/db_password.txt
   
   services:
     mariadb:
       secrets:
         - db_password
   ```

2. **Let's Encrypt:**
   - Use Certbot for real SSL certificates
   - Automate renewal

3. **Firewall Rules:**
   - Restrict Docker network access
   - Use `iptables` or `ufw`

4. **Regular Updates:**
   - Keep base images updated
   - Monitor security advisories

## 📊 Monitoring

### Health Checks

**MariaDB:**
```bash
test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "--silent"]
interval: 10s
timeout: 5s
retries: 5
start_period: 30s
```

**WordPress:**
```bash
test: ["CMD-SHELL", "pidof php-fpm7.4 || exit 1"]
interval: 10s
timeout: 5s
retries: 5
start_period: 40s
```

**NGINX:**
```bash
test: ["CMD", "curl", "-fk", "https://localhost:443"]
interval: 10s
timeout: 5s
retries: 3
start_period: 10s
```

### Viewing Health Status

```bash
# All services
docker compose -f srcs/docker-compose.yml ps

# Detailed health info
docker inspect mariadb --format='{{json .State.Health}}' | jq .
```

## 🧪 Testing

### Manual Testing Checklist

- [ ] All containers start and reach healthy state
- [ ] Website accessible at https://login.42.fr
- [ ] SSL certificate works (accept self-signed warning)
- [ ] WordPress admin panel accessible
- [ ] Can log in with admin credentials
- [ ] Can log in with additional user credentials
- [ ] Data persists after `docker compose down` and `up`
- [ ] All services restart on failure
- [ ] Logs show no errors

### Automated Health Verification

```bash
#!/bin/bash
# Simple health check script

echo "Waiting for services to be healthy..."
sleep 30

for service in mariadb wordpress nginx; do
    status=$(docker inspect $service --format='{{.State.Health.Status}}' 2>/dev/null)
    if [ "$status" = "healthy" ]; then
        echo "✅ $service is healthy"
    else
        echo "❌ $service is $status"
        exit 1
    fi
done

echo "✅ All services are healthy!"
```

## 🚧 Development Workflow

### Making Changes

1. **Edit configuration files**
2. **Stop services:** `make down`
3. **Rebuild:** `make`
4. **Test changes**
5. **View logs:** `make logs`

### Iterative Development

```bash
# Edit Dockerfile or scripts
nano srcs/requirements/nginx/tools/script.sh

# Rebuild only changed service
docker compose -f srcs/docker-compose.yml up -d --build nginx

# Check logs
docker compose -f srcs/docker-compose.yml logs -f nginx
```

### Clean Rebuild

```bash
# Remove everything
make fclean

# Rebuild from scratch
make

# Verify
make ps
```

## 📝 Subject Compliance Checklist

- ✅ All services in separate containers
- ✅ Custom Dockerfiles (no pre-built images)
- ✅ Debian bullseye-slim base (penultimate stable)
- ✅ No `latest` tags
- ✅ No passwords in Dockerfiles
- ✅ Environment variables in `.env`
- ✅ Restart policy: `unless-stopped`
- ✅ No infinite loops (`tail -f`, `sleep infinity`, etc.)
- ✅ NGINX with TLSv1.2/TLSv1.3 only, port 443
- ✅ WordPress with php-fpm only (no nginx)
- ✅ MariaDB only
- ✅ Two volumes (mariadb, wordpress)
- ✅ One Docker network (inception)
- ✅ Two WordPress users (admin + additional)
- ✅ Admin username not admin/administrator
- ✅ Domain: login.42.fr
- ✅ Volumes at /home/login/data
- ✅ Makefile at root
- ✅ All files in srcs/ folder

## � Implemented Bonus Services

### 1. Adminer - Database Management

**Implementation:**
- Base image: debian:bullseye-slim
- Single PHP file downloaded from adminer.org
- PHP built-in server (no Apache/NGINX needed)
- Port 8080 exposed

**Technical details:**
```bash
# Dockerfile installs: php-fpm, php-mysqli, curl, ca-certificates
# Script downloads adminer.org/latest.php
# Runs: php -S 0.0.0.0:8080
```

**Healthcheck:** `curl -f http://localhost:8080`

### 2. Redis Cache - Object Cache

**Implementation:**
- Base image: debian:bullseye-slim
- Redis server package
- Port 6379 (internal only, not exposed)
- WordPress plugin: redis-cache

**Technical details:**
```bash
# Dockerfile installs: redis-server
# Script runs: redis-server --bind 0.0.0.0 --protected-mode no
# WordPress installs plugin and configures via WP-CLI
```

**WordPress integration:**
- Plugin installed automatically in WordPress script
- Config set: WP_REDIS_HOST=redis, WP_REDIS_PORT=6379
- Enabled with: wp redis enable

**Healthcheck:** `redis-cli ping`

### 3. Docker Secrets - Secure Credential Management

**Implementation:**
- Secrets defined in docker-compose.yml
- Secret files stored in `srcs/.secrets/` (gitignored)
- Mounted in containers at `/run/secrets/`
- Read-only mount with restricted permissions

**Technical details:**
```yaml
# docker-compose.yml structure:
secrets:
  mysql_root_password:
    file: .secrets/mysql_root_password.txt
  # ... other secrets

services:
  mariadb:
    secrets:
      - mysql_root_password
      - mysql_user_password
```

**Script implementation:**
```bash
# In initialization scripts:
if [ -f /run/secrets/secret_name ]; then
  SECRET_VALUE=$(cat /run/secrets/secret_name)
fi
```

**Security benefits:**
- Secrets NOT visible in `docker inspect`
- Not in container environment variables
- Restricted permissions (400, root only)
- Not exposed in process listings
- Not inherited by child processes

**Secrets used:**
- `mysql_root_password` (MariaDB)
- `mysql_user`, `mysql_user_password` (MariaDB/WordPress)
- `wp_admin_user`, `wp_admin_pass` (WordPress)
- `wordpress_user`, `wordpress_user_password` (WordPress)
- `ftp_user`, `ftp_pass` (FTP)

### 4. Portainer - Docker Management Interface

**Implementation:**
- Base image: debian:bullseye-slim
- Portainer CE binary downloaded from GitHub
- Ports: 9443 (HTTPS), 8000 (edge agent)
- Mounts Docker socket for container management

**Technical details:**
```bash
# Dockerfile:
# - Downloads Portainer binary from official GitHub releases
# - Extracts and places in /opt/portainer/
# - Creates /data directory for persistent configuration
# - Exposes ports 9443 (web UI) and 8000 (agent tunnel)

# Runs with:
CMD ["/opt/portainer/portainer", "--bind=:9443", "--data=/data"]
```

**Docker socket mounting:**
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock  # Control Docker
  - portainer:/data  # Persistent configuration
```

**Features:**
- Full Docker API access via socket
- Container lifecycle management (start/stop/restart/remove)
- Image management (pull/remove/build)
- Network and volume administration
- Real-time container logs and stats
- Web-based terminal access to containers

**Security note:** 
- Socket access gives full Docker control
- Portainer itself should be password-protected
- First-time access requires admin account creation

**Healthcheck:** `wget --spider http://localhost:9443`

### 5. FTP Server - File Transfer

**Implementation:**
- Base image: debian:bullseye-slim
- vsftpd (Very Secure FTP Daemon)
- Ports: 21 (control), 21100-21110 (passive data)
- Mounts WordPress volume

**Technical details:**
```bash
# Dockerfile installs: vsftpd
# Script creates FTP user dynamically
# Configures vsftpd for passive mode
# Chroot users to /var/www/html
# Allows writeable chroot
```

**Security configuration:**
- Anonymous access disabled
- Local users only
- Chroot jail enabled
- Passive mode for firewalls

**Healthcheck:** None (FTP doesn't support HTTP checks)

## 🏗️ Bonus Architecture Details

### Service Dependencies

```
Mandatory:
mariadb → wordpress → nginx

Bonus:
mariadb → adminer (for DB access)
       → redis (independent, used by WordPress)
       → portainer (Docker management via socket)
       → ftp (mounts WordPress volume)

Docker Secrets → All services (secure credential storage)
```

### Port Mapping

| Service | Internal Port | External Port | Protocol |
|---------|--------------|---------------|----------|
| nginx | 443 | 443 | HTTPS |
| adminer | 8080 | 8080 | HTTP |
| portainer | 9443, 8000 | 9443, 8000 | HTTPS |
| ftp | 21, 21100-21110 | 21, 21100-21110 | FTP |
| wordpress | 9000 | - | FastCGI |
| mariadb | 3306 | - | MySQL |
| redis | 6379 | - | Redis |

### Volume Sharing

```
WordPress Volume (/var/www/html):
- Mounted by: wordpress (rw)
- Mounted by: nginx (ro)
- Mounted by: ftp (rw)
```

## 🎯 Bonus Justification

For defense, explain why each bonus is useful:

1. **Adminer:** Simplifies database management, useful for debugging, viewing data structure, running queries without terminal access.

2. **Redis:** Significantly improves WordPress performance by caching database queries in RAM. Real-world production use case.

3. **Portainer:** Professional Docker management interface. Visual container monitoring, logs access, resource statistics. Demonstrates understanding of DevOps tools and Docker ecosystem. Essential for production environments where GUI management is needed.

4. **FTP:** Allows remote file management, useful for uploading media, editing themes/plugins, traditional file transfer method still widely used.

**Additional Feature:**
- **Docker Secrets:** Enterprise-grade security for credential management. Much more secure than environment variables. Demonstrates understanding of security best practices and Docker's secret management system. Production-ready approach to handling sensitive data.

Each bonus must be justified and demonstrate value.

## 📚 Additional Resources

- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [NGINX Configuration](https://nginx.org/en/docs/)
- [WordPress CLI](https://wp-cli.org/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
