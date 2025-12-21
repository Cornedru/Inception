# Inception Project Structure

```
inception/
├── Makefile
└── srcs/
    ├── docker-compose.yml
    ├── .env
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── mariadb.conf
        │   └── tools/
        │       └── init.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   └── tools/
        │       └── init.sh
        └── nginx/
            ├── Dockerfile
            └── conf/
                └── nginx.conf
```

## Setup Instructions

### 1. Create the directory structure:
```bash
mkdir -p inception/srcs/requirements/{mariadb/{conf,tools},wordpress/tools,nginx/conf}
cd inception
```

### 2. Create all the files:
- Copy the Makefile to the root `inception/` directory
- Copy docker-compose.yml to `srcs/`
- Create `.env` file in `srcs/` with your configuration
- Copy Dockerfiles and configuration files to their respective directories

### 3. Configure your system:

#### Update /etc/hosts:
```bash
sudo nano /etc/hosts
```
Add this line (replace `your_login` with your actual login):
```
127.0.0.1    your_login.42.fr
```

#### Update .env file:
Edit `srcs/.env` and replace:
- `your_login` with your actual login
- All passwords with strong, unique passwords
- Email addresses with valid ones

### 4. Build and run:
```bash
make
```

### 5. Access your site:
Open your browser and navigate to:
```
https://your_login.42.fr
```

You'll see a security warning (self-signed certificate) - accept it to proceed.

## Important Notes

### Security:
- **Never commit the .env file to Git**
- Add `.env` to your `.gitignore`
- Use strong, unique passwords for all services
- The self-signed SSL certificate is for development only

### Volumes:
- Data is stored in `/home/your_login/data/`
- MariaDB data: `/home/your_login/data/mariadb`
- WordPress files: `/home/your_login/data/wordpress`

### Useful Commands:
```bash
make          # Build and start all services
make down     # Stop all services
make logs     # View logs from all containers
make clean    # Remove containers and images
make fclean   # Remove everything including data
make re       # Full rebuild
```

### Troubleshooting:

#### Containers not starting:
```bash
make logs
```

#### Check container status:
```bash
docker ps -a
```

#### Access a container:
```bash
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash
```

#### Reset everything:
```bash
make fclean
make
```

### WordPress Admin Access:
- URL: `https://your_login.42.fr/wp-admin`
- Username: As defined in WP_ADMIN_USER (e.g., superadmin)
- Password: As defined in WP_ADMIN_PASSWORD

### Database Access (from WordPress container):
```bash
docker exec -it wordpress bash
mysql -h mariadb -u wpuser -p
```

## Project Requirements Checklist

✅ NGINX with TLSv1.2/TLSv1.3 only
✅ WordPress + php-fpm (no NGINX)
✅ MariaDB (no NGINX)
✅ Volume for WordPress database
✅ Volume for WordPress files
✅ Docker network connecting containers
✅ Containers restart on crash
✅ No network: host or --link
✅ No infinite loops (tail -f, sleep infinity, etc.)
✅ Two WordPress users (admin + regular)
✅ Admin username doesn't contain "admin"
✅ Volumes in /home/login/data
✅ Domain points to local IP
✅ NGINX is only entrypoint via port 443
✅ No passwords in Dockerfiles
✅ Environment variables used
✅ Custom Dockerfiles (no pre-built images except Alpine/Debian)
✅ No "latest" tag used

## Architecture

```
Internet
    |
    | HTTPS (443)
    v
[NGINX Container]
    |
    | FastCGI (9000)
    v
[WordPress + PHP-FPM Container]
    |
    | MySQL (3306)
    v
[MariaDB Container]

Volumes:
- /home/login/data/wordpress → WordPress files
- /home/login/data/mariadb → Database files

Network: inception (bridge)
```
