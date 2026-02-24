# github-runner


Docker image untuk menjalankan **GitHub Actions self-hosted runner** di dalam container.

Image ini akan:

- **Register runner** ke repository yang kamu tentukan saat container start
- Menjalankan runner (`run.sh`)
- **Auto-cleanup** (remove runner) saat container dihentikan (SIGTERM/SIGINT)

## Quick start

1. Buat **runner token** dari GitHub:

- Repo: `Settings` -> `Actions` -> `Runners` -> `New self-hosted runner`
- Ambil token di langkah konfigurasi runner

2. Jalankan container:

```bash
docker run -d \
  --name github-runner \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e REPO_URL=https://github.com/username/repo \
  -e RUNNER_TOKEN=YOUR_TOKEN \
  jefriherditriyanto/github-runner:latest
```

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

- **Runner name** di-set ke `docker-runner`.
  Jika kamu menjalankan lebih dari 1 container runner untuk repo yang sama, nama ini akan bentrok. (Saat ini belum ada env var untuk mengubah nama.)
- **Work directory**: `_work`.
- Container berjalan sebagai user non-root `runner`.

## Examples

### Pin image version

```bash
docker run -d \
  --name github-runner \
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
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      REPO_URL: https://github.com/username/repo
      RUNNER_TOKEN: YOUR_TOKEN
```

## Security

- **Jangan hardcode** `RUNNER_TOKEN` di repository publik.
- Gunakan secret manager / environment injection dari platform kamu.
- Token runner dari GitHub biasanya **expired dalam waktu singkat**. Jika container restart setelah token expired, runner tidak bisa register.
- Mounting `/var/run/docker.sock` memberi container akses setara root ke Docker host. Jalankan image ini hanya di host yang kamu percayai.

## Troubleshooting

### `REPO_URL not set` / `RUNNER_TOKEN not set`

- Pastikan env var `REPO_URL` dan `RUNNER_TOKEN` sudah di-set.

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
