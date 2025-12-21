# User Documentation

This document provides user-facing instructions for operating and managing the Inception infrastructure.

## Table of Contents

1. [Overview](#overview)
2. [Starting the Project](#starting-the-project)
3. [Stopping the Project](#stopping-the-project)
4. [Accessing the Services](#accessing-the-services)
5. [Managing Credentials](#managing-credentials)
6. [Verifying Services](#verifying-services)
7. [Troubleshooting](#troubleshooting)

## Overview

The Inception project provides a complete web hosting infrastructure consisting of three main services:

### Services Provided

1. **NGINX Web Server**
   - Serves as the entry point to the infrastructure
   - Provides HTTPS/TLS encryption for secure connections
   - Acts as a reverse proxy to the WordPress application
   - Accessible on port 443

2. **WordPress Content Management System**
   - Full-featured website and blog platform
   - Includes administration panel for content management
   - Supports two user accounts (administrator and editor)
   - Processes dynamic PHP content

3. **MariaDB Database**
   - Stores all WordPress content and configuration
   - Not directly accessible from outside the container network
   - Provides data persistence across container restarts

All services are containerized and managed through Docker Compose, ensuring isolation, portability, and easy management.

## Starting the Project

### First-Time Setup

1. Ensure you are in the project root directory:
```bash
cd /path/to/inception
```

2. Verify that the secrets are configured (see [Managing Credentials](#managing-credentials)).

3. Start all services:
```bash
make
```

The first startup will take several minutes as it:
- Creates data directories
- Builds Docker images from scratch
- Initializes the database
- Downloads and configures WordPress
- Generates SSL certificates

You will see output indicating the progress of each service.

### Subsequent Starts

For subsequent starts, simply run:
```bash
make up
```

This command uses cached images and configuration, starting up in seconds.

### Checking Startup Progress

Monitor the logs to see when services are ready:
```bash
make logs
```

Press `Ctrl+C` to stop viewing logs (services continue running).

Look for these indicators of successful startup:
- **MariaDB**: "mysqld: ready for connections"
- **WordPress**: "wordpress [notice] fpm is running, pid X"
- **NGINX**: "start worker processes"

## Stopping the Project

### Graceful Shutdown

To stop all services while preserving data:
```bash
make down
```

This command:
- Stops all running containers
- Removes containers and networks
- Preserves all data in volumes
- Keeps Docker images for faster next startup

### Temporary Pause

To temporarily pause services without removing containers:
```bash
make stop
```

Resume with:
```bash
make start
```

## Accessing the Services

### Website

1. Open your web browser
2. Navigate to: **https://ndehmej.42.fr**
3. Accept the security warning about the self-signed certificate:
   - Click "Advanced" or "Show Details"
   - Click "Proceed to ndehmej.42.fr" or "Accept the Risk"

You should see your WordPress website homepage.

### WordPress Administration Panel

1. Navigate to: **https://ndehmej.42.fr/wp-admin**
2. Log in with administrator credentials:
   - **Username**: `supervisor` (or as configured in `.env`)
   - **Password**: See [Managing Credentials](#managing-credentials)

From the admin panel, you can:
- Create and edit posts and pages
- Manage media files
- Install themes and plugins
- Configure site settings
- Manage users

### Available Users

The system includes two WordPress users:

1. **Administrator** (`supervisor`):
   - Full access to all WordPress features
   - Can manage users, themes, plugins
   - Can modify site settings

2. **Author** (`bob`):
   - Can create and edit their own posts
   - Cannot access administrative features
   - Password: `bobpassword` (or as configured)

## Managing Credentials

### Locating Credentials

All sensitive credentials are stored in the `srcs/secrets/` directory:

```
srcs/secrets/
├── db_root_password.txt      # MariaDB root password
├── db_password.txt            # WordPress database user password
└── wp_admin_password.txt      # WordPress administrator password
```

### Viewing Credentials

To view a password:
```bash
cat srcs/secrets/wp_admin_password.txt
```

**Important**: These files should never be committed to Git or shared publicly.

### Changing Credentials

To change passwords:

1. Stop the project:
```bash
make down
```

2. Edit the secret files:
```bash
echo "new_strong_password" > srcs/secrets/wp_admin_password.txt
echo "new_db_password" > srcs/secrets/db_password.txt
echo "new_root_password" > srcs/secrets/db_root_password.txt
```

3. Remove existing data (this will delete your database):
```bash
make fclean
```

4. Restart the project:
```bash
make
```

**Warning**: Changing passwords requires rebuilding the database, which will delete all existing content.

### Other Configuration

Non-sensitive configuration is in `srcs/.env`:
- Domain name
- Database name
- Usernames
- Email addresses
- Site title

Edit this file directly and restart services for changes to take effect.

## Verifying Services

### Check Container Status

View running containers:
```bash
docker ps
```

Expected output should show three running containers:
- `nginx`
- `wordpress`
- `mariadb`

Each should have status "Up" with uptimes.

### Check Service Health

#### NGINX
Test NGINX is responding:
```bash
curl -k https://ndehmej.42.fr
```

You should receive HTML content.

#### WordPress
Access the WordPress site in your browser or check PHP-FPM:
```bash
docker exec -it wordpress ps aux | grep php-fpm
```

Should show running PHP-FPM processes.

#### MariaDB
Check database connectivity:
```bash
docker exec -it mariadb mysql -u wp_user -p$(cat srcs/secrets/db_password.txt) -e "SHOW DATABASES;"
```

Should list the `wordpress` database.

### View Service Logs

View logs from all services:
```bash
make logs
```

View logs from a specific service:
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Add `-f` to follow logs in real-time:
```bash
docker logs -f wordpress
```

### Check Data Persistence

Verify data directories exist and contain data:
```bash
ls -lh /home/ndehmej/data/mariadb/
ls -lh /home/ndehmej/data/wordpress/
```

The MariaDB directory should contain database files (`ib*`, `mysql/`, etc.).
The WordPress directory should contain WordPress files (`wp-admin/`, `wp-content/`, etc.).

### Network Connectivity

Verify containers can communicate:
```bash
docker exec -it wordpress ping -c 3 mariadb
docker exec -it nginx ping -c 3 wordpress
```

All pings should succeed.

## Troubleshooting

### Website Not Accessible

**Problem**: Cannot access https://ndehmej.42.fr

**Solutions**:
1. Check if NGINX container is running:
   ```bash
   docker ps | grep nginx
   ```

2. Verify `/etc/hosts` configuration:
   ```bash
   grep ndehmej.42.fr /etc/hosts
   ```
   Should show: `127.0.0.1    ndehmej.42.fr`

3. Check if port 443 is listening:
   ```bash
   sudo netstat -tlnp | grep 443
   ```

4. Review NGINX logs:
   ```bash
   docker logs nginx
   ```

### Database Connection Errors

**Problem**: WordPress shows "Error establishing a database connection"

**Solutions**:
1. Verify MariaDB is running:
   ```bash
   docker ps | grep mariadb
   ```

2. Check MariaDB logs for errors:
   ```bash
   docker logs mariadb
   ```

3. Test database connectivity from WordPress container:
   ```bash
   docker exec -it wordpress nc -zv mariadb 3306
   ```

4. Verify credentials match between `.env` and secrets files

### Containers Keep Restarting

**Problem**: Containers show status "Restarting" in `docker ps`

**Solutions**:
1. Check container logs for errors:
   ```bash
   docker logs <container_name>
   ```

2. Verify data directories have correct permissions:
   ```bash
   ls -ld /home/ndehmej/data/mariadb
   ls -ld /home/ndehmej/data/wordpress
   ```

3. Stop all containers and rebuild:
   ```bash
   make fclean
   make
   ```

### SSL Certificate Warnings

**Problem**: Browser shows certificate error

**Solution**: This is expected with self-signed certificates. Click "Advanced" and proceed. For production environments, use certificates from a trusted Certificate Authority (Let's Encrypt, etc.).

### Disk Space Issues

**Problem**: Build fails with "no space left on device"

**Solutions**:
1. Check available disk space:
   ```bash
   df -h
   ```

2. Clean up Docker resources:
   ```bash
   make clean
   docker system prune -a
   ```

3. Remove old Docker data:
   ```bash
   docker volume prune
   docker image prune -a
   ```

### Getting Additional Help

If issues persist:

1. Check the full logs from all services:
   ```bash
   make logs > logs.txt
   ```

2. Review the logs for error messages

3. Check the DEV_DOC.md for more technical troubleshooting steps

4. Ensure your system meets all prerequisites (Docker version, available resources)

## Regular Maintenance

### Backup

To backup your data:
```bash
# Stop services
make down

# Backup data directories
sudo tar -czf inception-backup-$(date +%Y%m%d).tar.gz /home/ndehmej/data/

# Restart services
make up
```

### Updates

To update the infrastructure:
```bash
# Stop and remove everything
make fclean

# Pull latest code
git pull

# Rebuild and restart
make
```

**Note**: This will delete existing data. Backup first if needed.

### Monitoring

Regularly check:
- Container status: `docker ps`
- Disk usage: `df -h /home/ndehmej/data/`
- Service logs: `make logs`
- Resource usage: `docker stats`

Monitor for:
- Containers with status other than "Up"
- Increasing disk usage
- Error messages in logs
- High CPU or memory usage
