# NSFWFetch Docker Setup

Complete Docker setup for running NSFWFetch CLI in a containerized environment on Linux.

## Quick Start

### Option 1: Using the Helper Script (Recommended)

```bash
bash src/scripts/opendockercli.sh
```

This script will:
- Check if Docker and docker-compose are installed
- Build the image if it's the first run
- Create a `downloads/` directory in the project root
- Open an interactive terminal inside the container

### Option 2: Using Docker Compose Directly

```bash
# Build the image
docker-compose build

# Run the container with interactive terminal
docker-compose run --rm nsfwfetch

# Or run with specific arguments
docker-compose run --rm nsfwfetch --help
```

### Option 3: Using Docker CLI Directly

```bash
# Build the image
docker build -t nsfwfetch .

# Run interactively
docker run -it -v ./downloads:/data nsfwfetch

# Or run with specific command
docker run -it -v ./downloads:/data nsfwfetch --help
```

## Usage Inside the Container

Once inside the terminal, you can use NSFWFetch normally:

```bash
# View help
python Porn_Fetch_CLI.py --help

# Download from a URL
python Porn_Fetch_CLI.py --url "https://example.com/video"

# Search and download
python Porn_Fetch_CLI.py --search "query"

# Download with specific options
python Porn_Fetch_CLI.py --url "https://example.com/video" --output /data/my_video.mp4
```

## Important Notes

### Downloads Location

- **Inside container:** `/data`
- **On your host machine:** `./downloads` (relative to project root)

Any files downloaded inside `/data` will automatically be saved to your `./downloads/` directory.

### File Permissions

Downloaded files will be owned by the `root` user inside the container. To change permissions after downloading:

```bash
# Make files readable by your user
sudo chmod -R 755 ./downloads

# Or change ownership
sudo chown -R $USER:$USER ./downloads
```

### Persistence

The container is ephemeral by default. Each time you run `docker-compose run`, a fresh container is created and removed when you exit.

- **Preserved:** Downloaded files in `/data` (stored on host in `./downloads`)
- **Not preserved:** Configuration, cookies, or other state in the container

If you need to preserve state, create a named volume:

```bash
docker volume create nsfwfetch-data
docker run -it -v nsfwfetch-data:/data nsfwfetch
```

## Troubleshooting

### "Permission denied" errors on downloads

The container runs as root. Fix permissions:

```bash
sudo chown -R $USER:$USER ./downloads
chmod -R u+w ./downloads
```

### "Cannot connect to Docker daemon"

Make sure Docker is running:

```bash
sudo systemctl start docker
```

Or add your user to the docker group:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Network issues in container

If you can't download files, the container might not have internet access. Check:

```bash
# Inside container
ping google.com

# Or check DNS
nslookup google.com
```

If networking doesn't work, rebuild without cache:

```bash
docker-compose build --no-cache
```

### "Port already in use"

This setup doesn't use exposed ports, but if you get this error, try:

```bash
docker-compose down
```

## Advanced Usage

### Running Multiple Instances

```bash
# Terminal 1
docker-compose run --rm --name nsfwfetch1 nsfwfetch

# Terminal 2
docker-compose run --rm --name nsfwfetch2 nsfwfetch
```

### Using Environment Variables

Create a `.env` file in the project root:

```env
DOWNLOAD_PATH=./downloads
```

Then reference in docker-compose.yml:

```yaml
volumes:
  - ${DOWNLOAD_PATH}:/data
```

### Custom Command Execution

```bash
# Run specific Python command
docker-compose run --rm nsfwfetch python Porn_Fetch_CLI.py --url "https://example.com/video"

# Run shell commands
docker-compose run --rm nsfwfetch sh -c "ls -la /data"
```

## System Requirements

- **OS:** Linux (any distribution with Docker support)
- **Docker:** 20.10+
- **docker-compose:** 1.29+
- **Disk space:** At least 2GB for image + space for downloads
- **RAM:** 2GB minimum, 4GB+ recommended
- **Internet:** Required for downloading content

## Cleanup

To remove images and free up space:

```bash
# Remove unused containers
docker container prune

# Remove unused images
docker image prune

# Remove everything (be careful!)
docker system prune -a

# Remove specific image
docker rmi nsfwfetch:latest
```

## Security Notes

1. **SSL Certificate Issues:** If you encounter SSL errors, the container includes `certifi` for certificate verification.

2. **Privacy:** Downloaded content is stored locally in `./downloads`. Consider privacy when storing sensitive content.

3. **Terms of Service:** NSFWFetch violates ToS of associated websites. Use responsibly and at your own risk.

4. **Network:** The container has full network access. Use a proxy if needed:

```bash
docker-compose run --rm -e HTTP_PROXY=http://proxy:port nsfwfetch
```

## Performance Tips

1. **Use named volumes for repeated use:**
   ```bash
   docker volume create nsfwfetch-cache
   docker run -v nsfwfetch-cache:/data nsfwfetch
   ```

2. **Enable BuildKit for faster builds:**
   ```bash
   DOCKER_BUILDKIT=1 docker-compose build
   ```

3. **Use `.dockerignore` to exclude unnecessary files** (already configured)

## License

NSFWFetch is licensed under GPL-3.0. See LICENSE file for details.
