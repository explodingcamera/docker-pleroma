# Pleroma Docker

Simple Docker image for [Pleroma](https://pleroma.social/).
Currently, only x86_64 is supported. If you want to run Pleroma on other architectures, you should be able to build it yourself using the Dockerfile. I don't run a Pleroma instance myself anymore so there might be some issues with the image whenever a new pleroma version is released.

# Supported tags

- [`latest`](https://github.com/explodingcamera/docker-pleroma/pkgs/container/pleroma) - latest stable release
- [`3`](https://github.com/explodingcamera/docker-pleroma/pkgs/container/pleroma) - latest 3.x release
- [`3.15`](https://github.com/explodingcamera/docker-pleroma/pkgs/container/pleroma) - specific minor version
- [`3.15.1`](https://github.com/explodingcamera/docker-pleroma/pkgs/container/pleroma) - specific version
- [`develop`](https://github.com/explodingcamera/docker-pleroma/pkgs/container/pleroma) - latest develop branch build

Versions are build automatically using GitHub Actions weekly.

# How to use this image

## Start a Pleroma instance

**Docker Compose**

```yaml
version: "3.8"

services:
  db:
    image: postgres:17-alpine
    container_name: pleroma_db
    restart: always
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "pleroma"]
    environment:
      POSTGRES_USER: pleroma
      POSTGRES_PASSWORD: ChangeMe!
      POSTGRES_DB: pleroma
    volumes:
      - ./data/postgres:/var/lib/postgresql/data
  web:
    image: ghcr.io/explodingcamera/pleroma:stable
    container_name: pleroma_web
    healthcheck:
      test:
        ["CMD-SHELL", "wget -q --spider --proxy=off localhost:4000 || exit 1"]
    restart: always
    ports:
      - "4000:4000"
    volumes:
      - ./data/uploads:/data/uploads
      - ./data/static:/data/static
      - ./custom-config.exs:/data/config.exs
    environment:
      PUID: 1000
      PGID: 1000
      DOMAIN: example.com
      INSTANCE_NAME: Pleroma
      ADMIN_EMAIL: admin@example.com
      NOTIFY_EMAIL: notify@example.com
      DB_USER: pleroma
      DB_PASS: ChangeMe!
      DB_NAME: pleroma
    depends_on:
      - db
```

**Docker CLI**

```bash
docker run -d \
  --name=pleroma \
  -e PUID=1000 \
  -e PGID=1000 \
  -e DOMAIN="example.com"
  -e INSTANCE_NAME="Pleroma"
  -e ADMIN_EMAIL="admin@example.com"
  -e NOTIFY_EMAIL="notify@example.com"
  -e DB_USER="pleroma"
  -e DB_PASS="ChangeMe!"
  -e DB_NAME="pleroma"
  -p 4000:4000 \
  -v /path/to/static:/data/static \
  -v /path/to/uploads:/data/uploads \
  -v /path/to/customconfig:/data/config.exs \ # optional
  --restart unless-stopped \
  ghcr.io/explodingcamera/pleroma:stable
```

# Running Commands

```bash
$ docker exec -it pleroma_web ./cli.sh user new <username> <your@emailaddress> --admin
```

# Configuration

## Environment variables

- `PUID` - User ID (default: `1000`)
- `PGID` - Group ID (default: `1000`)
- `DOMAIN` - Domain name (default: `example.com`)

## Pleroma configuration

See [Pleroma documentation](https://docs.pleroma.social/backend/configuration/auth/) for more information.

`custom-config.exs`

```elixir
import Config

config :pleroma, :instance,
  registrations_open: false

config :pleroma, Pleroma.Web.Endpoint,
  url: [host: "pleroma.example.org"]

config :pleroma, Pleroma.Web.WebFinger, domain: "example.org"
```

# Build-time variables

- `PLEROMA_VERSION` - Pleroma version to build (default: `stable`)
- `PLEROMA_REPO` - Pleroma repository to clone (default: `https://git.pleroma.social/pleroma/pleroma.git`)
- `EXTRA_PKGS` - Extra packages to install (default: `imagemagick libmagic ffmpeg`)

# Other Docker images

- [angristan/docker-pleroma](https://github.com/angristan/docker-pleroma)
- [potproject/docker-pleroma](https://github.com/potproject/docker-pleroma)
- [rysiek/docker-pleroma](https://git.pleroma.social/rysiek/docker-pleroma)
- [RX14/iscute.moe](https://github.com/RX14/kurisu.rx14.co.uk/blob/master/services/iscute.moe/pleroma/Dockerfile)
