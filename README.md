# github-runner

Docker image untuk menjalankan **GitHub Actions self-hosted runner** dengan **Docker-in-Docker (DinD)**.

Runner ini bisa menjalankan workflow yang membutuhkan `docker build`, `docker push`, dan `docker compose` langsung di dalam container — tanpa perlu mount Docker socket dari host.

Image ini akan:

- **Start Docker daemon** (`dockerd`) di dalam container
- **Register runner** ke repository yang kamu tentukan
- Menjalankan runner (`run.sh`)
- **Auto-cleanup** (remove runner + stop `dockerd`) saat container dihentikan (SIGTERM/SIGINT)

## Quick start

1. Buat **runner token** dari GitHub:

- Repo: `Settings` → `Actions` → `Runners` → `New self-hosted runner`
- Ambil token di langkah konfigurasi runner

2. Jalankan container:

```bash
docker run -d \
  --name github-runner \
  --privileged \
  -e REPO_URL=https://github.com/username/repo \
  -e RUNNER_TOKEN=YOUR_TOKEN \
  jefriherditriyanto/github-runner:latest
```

> **`--privileged` wajib** agar `dockerd` bisa berjalan di dalam container.

3. Cek log:

```bash
docker logs -f github-runner
```

## Configuration

### Environment variables

Wajib:

- **`REPO_URL`**: URL repository GitHub, contoh `https://github.com/org/repo`
- **`RUNNER_TOKEN`**: token runner dari GitHub (bersifat sementara / short-lived)

## Notes

- **Base image**: `docker:dind` (Alpine-based)
- **Runner name** di-set ke `docker-runner`.
  Jika kamu menjalankan lebih dari 1 container runner untuk repo yang sama, nama ini akan bentrok.
- **Work directory**: `_work`.
- GitHub Actions runner berjalan sebagai user non-root `runner`, sedangkan `dockerd` berjalan sebagai root.
- Docker data disimpan di volume `/var/lib/docker` (otomatis di-manage Docker).

## Examples

### Pin image version

```bash
docker run -d \
  --name github-runner \
  --privileged \
  -e REPO_URL=https://github.com/username/repo \
  -e RUNNER_TOKEN=YOUR_TOKEN \
  jefriherditriyanto/github-runner:<tag>
```

### docker-compose

```yaml
services:
  github-runner:
    image: jefriherditriyanto/github-runner:latest
    container_name: github-runner
    restart: unless-stopped
    privileged: true
    environment:
      REPO_URL: https://github.com/username/repo
      RUNNER_TOKEN: YOUR_TOKEN
```

## Security

- **Jangan hardcode** `RUNNER_TOKEN` di repository publik.
- Gunakan secret manager / environment injection dari platform kamu.
- Token runner dari GitHub biasanya **expired dalam waktu singkat**. Jika container restart setelah token expired, runner tidak bisa register.
- **`--privileged`** memberi container akses penuh ke kernel host. Jalankan image ini hanya di host yang kamu percayai.

## Troubleshooting

### `REPO_URL not set` / `RUNNER_TOKEN not set`

- Pastikan env var `REPO_URL` dan `RUNNER_TOKEN` sudah di-set.

### `Docker daemon failed to start after 30s`

- Pastikan container dijalankan dengan `--privileged`.
- Cek log: `docker logs github-runner`.

### Runner tidak muncul di GitHub

- Pastikan `REPO_URL` benar (format `https://github.com/<owner>/<repo>`)
- Pastikan token masih valid (buat token baru jika perlu)
- Lihat log container:

```bash
docker logs -f github-runner
```

## Image tags

- `latest`: build terbaru
- `<git-sha>`: build berdasarkan commit SHA
