# ✅ Defense Checklist - Inception Project

This checklist helps you verify all requirements before your defense.

## 📋 Pre-Defense Preparation

### Project Files
- [ ] All files are in the `srcs/` folder
- [ ] Makefile exists at root
- [ ] README.md exists with all required sections
- [ ] USER_DOC.md exists at root
- [ ] DEV_DOC.md exists at root
- [ ] LICENSE file exists (optional but present)
- [ ] .gitignore properly configured
- [ ] .env.example exists as template
- [ ] .env is NOT committed (check with `git status`)

### Environment Configuration
- [ ] `.env` file configured with YOUR values
- [ ] `DOMAIN_NAME` set to your-login.42.fr
- [ ] `LOGIN` set to your 42 login
- [ ] `WP_ADMIN_USER` is NOT "admin" or "administrator"
- [ ] All passwords are secure (not "password123")
- [ ] Domain added to `/etc/hosts` pointing to 127.0.0.1

## 🐳 Docker Requirements

### General Rules
- [ ] Each service runs in its own container
- [ ] Each Docker image has same name as service
- [ ] All Dockerfiles use Debian Bullseye (not latest)
- [ ] No `latest` tags in FROM statements
- [ ] No passwords hardcoded in Dockerfiles
- [ ] All sensitive data in environment variables
- [ ] All containers have `restart: unless-stopped`
- [ ] No infinite loops (no `tail -f`, `sleep infinity`, `while true`)
- [ ] No `network: host`, `links`, or `--link`
- [ ] Dockerfiles are custom-written (not pulled images)

### Services Configuration
- [ ] NGINX container with TLSv1.2/TLSv1.3 only
- [ ] NGINX listens on port 443 only
- [ ] WordPress container with php-fpm only (no nginx)
- [ ] WordPress on port 9000 (internal)
- [ ] MariaDB container (not MySQL)
- [ ] MariaDB on port 3306 (internal, not exposed)

### Volumes
- [ ] One volume for WordPress database
- [ ] One volume for WordPress files
- [ ] Volumes use bind mounts (not Docker volumes)
- [ ] Bind mounts point to `~/data/mariadb` and `~/data/wordpress`
- [ ] Directories exist: `ls -la ~/data/`

### Network
- [ ] One Docker network connects all containers
- [ ] Network name is `inception`
- [ ] Network driver is `bridge`
- [ ] Only port 443 exposed to host

### WordPress Requirements
- [ ] Database contains TWO users
- [ ] One user is administrator
- [ ] Admin username does NOT contain "admin" or "administrator"
- [ ] Second user has different role (author)
- [ ] Domain configured as login.42.fr

## 🧪 Functional Tests

### Build and Start
```bash
# Clean start
make fclean
make

# Verify all services start
make ps
```
- [ ] All containers show status: `Up`
- [ ] All containers show `(healthy)` status
- [ ] No errors in `make logs`

### Website Access
- [ ] Can access `https://your-login.42.fr` in browser
- [ ] SSL certificate warning appears (expected for self-signed)
- [ ] Can proceed past SSL warning
- [ ] WordPress homepage loads correctly
- [ ] Can access `https://your-login.42.fr/wp-admin`

### User Access
- [ ] Can log in with admin credentials
- [ ] Admin has full access to WordPress dashboard
- [ ] Can log in with second user credentials
- [ ] Second user has limited access (author role)
- [ ] Can create and publish posts

### Data Persistence
```bash
# Test 1: Stop and restart
make down
make
# Check: Website still works, data intact

# Test 2: Remove containers
docker compose -f srcs/docker-compose.yml down
docker compose -f srcs/docker-compose.yml up -d
# Check: Website still works, data intact
```
- [ ] WordPress content persists after `make down` and `make`
- [ ] Database data persists
- [ ] No re-initialization on restart

### Container Restart Policy
```bash
# Kill a container
docker kill nginx
# Wait 10 seconds
docker ps
```
- [ ] Container automatically restarts
- [ ] Service becomes healthy again
- [ ] No manual intervention needed

## 📚 Documentation

### README.md
- [ ] First line in italic: "This project has been created as part of the 42 curriculum by your-login"
- [ ] Description section exists
- [ ] Instructions section exists
- [ ] Resources section exists
- [ ] Resources mention AI usage
- [ ] Comparison: Virtual Machines vs Docker
- [ ] Comparison: Secrets vs Environment Variables
- [ ] Comparison: Docker Network vs Host Network
- [ ] Comparison: Docker Volumes vs Bind Mounts

### USER_DOC.md
- [ ] Explains provided services
- [ ] Explains how to start/stop project
- [ ] Explains how to access website and admin panel
- [ ] Explains how to manage credentials
- [ ] Explains how to check services status

### DEV_DOC.md
- [ ] Explains setup from scratch
- [ ] Explains build and launch using Makefile
- [ ] Explains Docker Compose usage
- [ ] Explains container management
- [ ] Explains volume management
- [ ] Explains data persistence mechanism

## 🎯 Defense Questions Preparation

### Docker Concepts
Prepare to explain:
- [ ] What is Docker vs VM?
- [ ] What are containers vs images?
- [ ] What is Docker Compose?
- [ ] What is a Docker network?
- [ ] What are Docker volumes?
- [ ] What is a bind mount?
- [ ] What is a healthcheck?
- [ ] What is PID 1 problem?

### Your Implementation
Be ready to explain:
- [ ] Why you chose Debian Bullseye
- [ ] Why bind mounts instead of volumes
- [ ] How NGINX communicates with WordPress
- [ ] How WordPress communicates with MariaDB
- [ ] How SSL/TLS is configured
- [ ] How initialization scripts work
- [ ] Why you used marker files
- [ ] How restart policies work

### Configuration Files
Be able to show and explain:
- [ ] docker-compose.yml structure
- [ ] Each Dockerfile
- [ ] Each initialization script
- [ ] NGINX configuration
- [ ] MariaDB configuration
- [ ] Environment variables

### Commands
Know how to:
- [ ] Build the project: `make`
- [ ] Stop the project: `make down`
- [ ] View logs: `make logs`
- [ ] Check status: `make ps`
- [ ] Enter a container: `docker exec -it [name] bash`
- [ ] Rebuild specific service: `docker compose -f srcs/docker-compose.yml up -d --build [service]`
- [ ] View networks: `docker network ls`
- [ ] Inspect container: `docker inspect [name]`

## 🔧 Common Defense Tasks

### Task: Show the project working
```bash
make
# Wait for healthy status
make ps
# Open browser to https://your-login.42.fr
```

### Task: Show data persistence
```bash
# Create a post in WordPress admin
# Stop containers
make down
# Start again
make
# Show post still exists
```

### Task: Show restart policy
```bash
# Kill a container
docker kill nginx
# Show it restarts
sleep 5
docker ps | grep nginx
```

### Task: Show no infinite loops
```bash
# Show each script ends with proper exec command
cat srcs/requirements/nginx/tools/script.sh
cat srcs/requirements/wordpress/tools/script.sh
cat srcs/requirements/mariadb/tools/script.sh
```

### Task: Modify configuration
```bash
# Edit environment variable
nano srcs/.env
# Rebuild affected service
make down
make
# Show change applied
```

### Task: Show network isolation
```bash
# Show only port 443 exposed
docker ps
# Show internal communication
docker network inspect inception
```

## ⚠️ Common Pitfalls

### During Defense
- [ ] Don't say you don't understand something AI generated
- [ ] Don't have "admin" as admin username
- [ ] Don't have infinite loops in scripts
- [ ] Don't use `network: host`
- [ ] Don't have passwords in Dockerfiles
- [ ] Don't use `latest` tag in Dockerfiles
- [ ] Don't have .env committed to Git

### Technical
- [ ] Ensure all services are healthy before demo
- [ ] Know where logs are: `make logs`
- [ ] Know how to restart if something breaks: `make down && make`
- [ ] Have backup commands ready if Makefile fails
- [ ] Test everything before defense

## 📊 Quick Reference

### Essential Commands
```bash
# Start everything
make

# Stop everything
make down

# View logs
make logs

# Check status
make ps

# Clean and restart
make fclean && make

# Enter container
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
```

### File Locations
- Configuration: `srcs/docker-compose.yml`
- Environment: `srcs/.env`
- Data: `~/data/mariadb/` and `~/data/wordpress/`
- Dockerfiles: `srcs/requirements/*/Dockerfile`
- Scripts: `srcs/requirements/*/tools/script.sh`

### Service URLs
- Website: `https://your-login.42.fr`
- Admin: `https://your-login.42.fr/wp-admin`

## ✅ Final Verification

Before defense:
1. [ ] Clean rebuild: `make fclean && make`
2. [ ] All services healthy: `make ps`
3. [ ] Website accessible
4. [ ] Can log in with both users
5. [ ] Documentation is accurate
6. [ ] You understand every line of code
7. [ ] You can explain all choices made
8. [ ] You tested all commands

## 🎓 Defense Tips

1. **Be confident:** You built this, you understand it
2. **Be honest:** If you used AI, explain how and why
3. **Be thorough:** Show don't just tell
4. **Be prepared:** Have terminal and browser ready
5. **Be calm:** If something breaks, you know how to fix it

---

Good luck with your defense! 🚀
