# Inception

## Description

Inception is a system administration and DevOps project that involves setting up a complete web infrastructure using Docker containers. The goal is to virtualize several Docker images by creating them within a personal virtual machine, demonstrating proficiency in containerization, networking, and service orchestration.

The project implements a three-tier architecture consisting of:
- **NGINX** as a reverse proxy with TLS encryption (TLSv1.2/1.3)
- **WordPress** with PHP-FPM for dynamic content generation
- **MariaDB** as the database backend

Each service runs in its own isolated container, communicating through a dedicated Docker network. The infrastructure uses Docker volumes for persistent data storage and implements security best practices including Docker secrets for sensitive credentials.

## Instructions

### Prerequisites

- A virtual machine running Linux (Debian/Ubuntu recommended)
- Docker Engine installed
- Docker Compose installed
- Make utility installed
- At least 4GB of available disk space

### Installation

1. Clone the repository:
```bash
git clone https://github.com/Cornedru/Inception
cd Inception
```

2. Configure the `/etc/hosts` file to point your domain to localhost:
```bash
sudo nano /etc/hosts
```
Add the following line:
```
127.0.0.1    ndehmej.42.fr
```

3. Create the secrets directory and generate secure passwords:
```bash
mkdir -p srcs/secrets
echo "your_strong_root_password" > srcs/secrets/db_root_password.txt
echo "your_strong_db_password" > srcs/secrets/db_password.txt
echo "your_strong_admin_password" > srcs/secrets/wp_admin_password.txt
chmod 600 srcs/secrets/*.txt
```

4. Review and customize the environment variables in `srcs/.env` if needed.

### Compilation and Execution

Build and start all services:
```bash
make
```

This command will:
- Create the necessary data directories
- Build all Docker images from scratch
- Start all containers in detached mode

### Stopping the Project

To stop all services:
```bash
make down
```

### Cleaning



To remove all data from maria db & wordpress:
```bash
make clean_data
```

To remove all containers and images:
```bash
make clean
```

To remove everything including persistent data:
```bash
make fclean
```

To rebuild from scratch:
```bash
make re
```

### Accessing the Services

- **Website**: https://ndehmej.42.fr
- **WordPress Admin Panel**: https://ndehmej.42.fr/wp-admin
  - Username: `supervisor` (as defined in .env)
  - Password: Content of `srcs/secrets/wp_admin_password.txt`

Note: You will see a security warning due to the self-signed SSL certificate. This is expected for local development.

## Project Architecture

### Docker vs Virtual Machines

**Virtual Machines** provide full operating system isolation with their own kernel, which results in:
- Higher resource consumption (RAM, CPU, storage)
- Slower startup times (minutes)
- Complete isolation at the hardware level
- Better for running multiple different OS environments

**Docker containers** share the host OS kernel and provide process-level isolation:
- Lightweight and efficient resource usage
- Fast startup times (seconds)
- Easier to version control and distribute
- Better for microservices architecture
- This project uses Docker for its efficiency and portability

### Secrets vs Environment Variables

**Environment Variables** (`srcs/.env`):
- Store non-sensitive configuration like domain names, database names, usernames
- Easily accessible and readable
- Suitable for development settings

**Docker Secrets** (`srcs/secrets/*.txt`):
- Store sensitive data like passwords and API keys
- Mounted as read-only files in `/run/secrets/` inside containers
- Not stored in environment variables or logs
- More secure for production environments
- This project uses secrets for all passwords to follow security best practices

### Docker Network vs Host Network

**Host Network** (`--network host`):
- Container shares the host's network stack
- No network isolation
- Direct access to all host ports
- Not recommended for security reasons

**Docker Bridge Network** (used in this project):
- Isolated network namespace for containers
- Internal DNS resolution between containers
- Port mapping controls external access
- Better security through network isolation
- Only NGINX exposes port 443 to the host

### Docker Volumes vs Bind Mounts

**Bind Mounts**:
- Direct mapping of host directories to container paths
- Full control over the exact host location
- Used in this project for data persistence at `/home/ndehmej/data`
- Allows easy backup and inspection of data

**Docker Volumes**:
- Managed by Docker daemon
- Stored in Docker's storage directory
- Better performance on some platforms
- More portable across different hosts

This project uses bind mounts to meet the requirement of storing data in `/home/login/data` while leveraging Docker's volume syntax for proper lifecycle management.

## Technical Choices

1. **Alpine Linux 3.19**: Chosen as the base image for all containers due to its small size (~5MB) and security-focused design.

2. **Service Separation**: Each service (NGINX, WordPress, MariaDB) runs in its own container following the single-responsibility principle.

3. **TLS-Only Access**: NGINX is configured to accept only TLSv1.2 and TLSv1.3 connections, ensuring encrypted communication.

4. **WP-CLI**: Used for WordPress installation and configuration, enabling fully automated and reproducible deployments.

5. **Init Scripts**: Custom entrypoint scripts handle service initialization and configuration without using infinite loops or hacky workarounds.

6. **Proper PID 1**: Each container runs its main process as PID 1 with proper signal handling, ensuring graceful shutdowns and restarts.

## Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [Alpine Linux Wiki](https://wiki.alpinelinux.org/)

### Tutorials and Articles
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Understanding PID 1 in Docker](https://cloud.google.com/architecture/best-practices-for-building-containers#signal-handling)
- [Docker Security Best Practices](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)

