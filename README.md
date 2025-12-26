# 🐳 Inception

*This project has been created as part of the 42 curriculum by lvarela*

## Description

A Docker infrastructure project that sets up a complete web stack with NGINX, WordPress, and MariaDB. This project demonstrates containerization, orchestration, and system administration skills by building a multi-service infrastructure from scratch using Docker Compose.

## 📋 Overview

This project creates a small infrastructure using Docker Compose with the following services:

- **NGINX** - Web server with TLSv1.2/TLSv1.3 support
- **WordPress** - CMS with PHP-FPM 7.4
- **MariaDB** - Database server

Each service runs in its own container built from custom Dockerfiles using Debian Bullseye.

## 🚀 Quick Start

### Prerequisites

- Docker Engine (20.10+)
- Docker Compose (2.0+)
- Make (optional)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/inception.git
cd inception
```

2. **Configure environment**
```bash
cp srcs/.env.example srcs/.env
nano srcs/.env  # Edit with your values
```

3. **Add domain to hosts file**
```bash
sudo nano /etc/hosts
# Add: 127.0.0.1 your-login.42.fr
```

4. **Launch the project**
```bash
make
```

5. **Access the site**
- WordPress: https://your-login.42.fr
- Admin panel: https://your-login.42.fr/wp-admin

## ⚙️ Configuration

### Environment Variables

Edit `srcs/.env` with your configuration:

```bash
# Domain
DOMAIN_NAME=your-login.42.fr
LOGIN=your-login

# MariaDB
MYSQL_ROOT_PASSWORD=secure_password
MYSQL_DATABASE=wordpress_db
MYSQL_USER=wordpress_user
MYSQL_USER_PASSWORD=secure_password
DB_HOST=mariadb

# WordPress Admin
PROJECT=Inception
WP_ADMIN_USER=admin
WP_ADMIN_PASS=secure_password

# WordPress Additional User
WORDPRESS_USER=author
WORDPRESS_USER_EMAIL=author@example.com
WORDPRESS_USER_PASSWORD=secure_password
```

## 🎯 Usage

### Makefile Commands

```bash
make        # Build and start all services
make down   # Stop and remove containers
make stop   # Stop services
make restart # Restart services
make logs   # View logs
make ps     # Show container status
make clean  # Clean data directories
make fclean # Remove everything (containers, images, volumes)
make destroy # Nuclear option: remove ALL Docker resources
```

### Docker Compose Commands

```bash
docker compose -f srcs/docker-compose.yml up -d --build
docker compose -f srcs/docker-compose.yml down
docker compose -f srcs/docker-compose.yml logs -f
```

## 📁 Project Structure

```
inception/
├── Makefile
├── README.md
└── srcs/
    ├── docker-compose.yml
    ├── .env.example
    ├── ssl/                     # Generated SSL certificates
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/50-server.cnf
        │   └── tools/script.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/default.conf
        │   └── tools/script.sh
        └── wordpress/
            ├── Dockerfile
            └── tools/script.sh
```

## 🏗️ Architecture

```
┌─────────────────────┐
│       NGINX         │  Port: 443 (TLS)
│   (Web Server)      │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│     WordPress       │  Port: 9000
│     (PHP-FPM)       │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│      MariaDB        │  Port: 3306
│     (Database)      │
└─────────────────────┘
```

## 🔍 Technical Details

### Volumes
Data persists in bind mounts:
- `~/data/mariadb` → MariaDB data
- `~/data/wordpress` → WordPress files

### Network
- Bridge network named `inception`
- Services communicate via service names
- Only port 443 exposed to host

### Security
- SSL/TLS with self-signed certificates
- Network isolation
- Health checks for proper service orchestration
- Restart policy: `unless-stopped`
- Domain-based configuration

## 🐛 Troubleshooting

### Port 443 Already in Use
```bash
sudo lsof -i :443  # Find process using the port
```

### View Logs
```bash
docker compose -f srcs/docker-compose.yml logs -f [service_name]
```

### Reset Everything
```bash
make fclean
rm -rf ~/data/mariadb ~/data/wordpress
make
```

### Permission Issues
```bash
mkdir -p ~/data/mariadb ~/data/wordpress
chmod -R 755 ~/data
```

## 📚 Resources

### Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [NGINX Docs](https://nginx.org/en/docs/)
- [WordPress](https://wordpress.org/support/)
- [MariaDB](https://mariadb.org/documentation/)

### AI Usage
This project was developed with assistance from AI tools (GitHub Copilot) for:
- Optimizing Dockerfile best practices
- Debugging shell scripts and Docker Compose configurations
- Generating documentation structure
- Understanding Docker networking and volume management

All AI-generated code was reviewed, tested, and understood before integration.

## 🔬 Technical Concepts

### Virtual Machines vs Docker

**Virtual Machines (VMs):**
- Full OS virtualization with hypervisor
- Each VM includes complete guest OS
- Higher resource overhead (GB of RAM, disk)
- Slower startup times (minutes)
- Strong isolation at hardware level

**Docker Containers:**
- OS-level virtualization, shares host kernel
- Only application and dependencies packaged
- Minimal resource overhead (MB of RAM, disk)
- Fast startup times (seconds)
- Process-level isolation with namespaces/cgroups

**Why Docker for this project:**
- Lightweight and efficient for web services
- Fast iteration and development
- Easy reproducibility across environments
- Better resource utilization

### Secrets vs Environment Variables

**Environment Variables:**
- Stored in plain text in `.env` file or shell
- Visible in process listing (`docker inspect`)
- Suitable for non-sensitive configuration (ports, domains)
- Simple to use and debug
- Used in this project for simplicity

**Docker Secrets:**
- Encrypted during transit and at rest
- Mounted as in-memory files in `/run/secrets/`
- Not visible in `docker inspect` or logs
- Require Docker Swarm or Compose with secrets support
- Best practice for production passwords/keys

**Note:** This project uses environment variables for educational purposes. Production deployments should use Docker secrets for sensitive data.

### Docker Network vs Host Network

**Docker Network (bridge):**
- Isolated network for containers
- Service discovery via container names
- Port mapping required for external access
- Better security through isolation
- Used in this project (`inception` bridge network)

**Host Network:**
- Container shares host's network stack
- No network isolation
- No port mapping needed
- Performance benefit (no NAT overhead)
- Security risk - not recommended
- **Forbidden in subject requirements**

### Docker Volumes vs Bind Mounts

**Docker Volumes:**
- Managed by Docker in `/var/lib/docker/volumes/`
- Created and destroyed with `docker volume` commands
- Portable across hosts
- Better performance on some systems
- Docker handles permissions

**Bind Mounts:**
- Mount host directory directly into container
- Full path specified (`/home/user/data`)
- Changes immediately visible on host
- User controls permissions and location
- Used in this project for easy access and subject compliance

**Why Bind Mounts here:**
- Subject requires volumes at `/home/login/data`
- Easy inspection and backup from host
- Direct access for troubleshooting
- Meets project requirements explicitly

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details.

---

Made with ❤️ for 42 School

