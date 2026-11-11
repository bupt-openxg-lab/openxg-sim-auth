# openxg-sim-auth — Deployment Guide

Copy everything in this folder to the target machine (keep these files together):

| File | Description |
|------|-------------|
| `openxg-sim-auth.tar.gz` | Application bundle |
| `deploy.sh` | Installs PC/SC and extracts the archive (requires root) |
| `README.md` | This guide |

## 1. Requirements

- Linux x86_64 (Ubuntu 22.04 or newer recommended; should match or exceed the build host)
- USB smart card reader (CCID class) with a USIM/SIM inserted

## 2. Deploy

From **this directory** (`deploy.sh` next to `openxg-sim-auth.tar.gz`):

```bash
sudo ./deploy.sh
```

The script will:

1. Install `pcscd` and `pcsc-tools` (includes `pcsc_scan`)
2. Start and enable `pcscd`
3. Extract `openxg-sim-auth.tar.gz` into subdirectory `openxg-sim-auth/`

Optional — verify reader and card:

```bash
pcsc_scan
```

When you see **Card inserted** and an ATR, press `Ctrl+C` to exit.

## 3. Start the service

```bash
cd openxg-sim-auth
./openxg-sim-auth --host 0.0.0.0 --port 9090
```

| Option | Meaning | Default |
|--------|---------|---------|
| `--host` | Bind address | `0.0.0.0` |
| `--port` | TCP port | `9090` |

On success you should see:

```text
Serving at http://0.0.0.0:9090/authentication/5g_aka
```

If the port is busy: `sudo ss -tlnp | grep 9090`, then stop the old process.

## 4. Verify

```bash
curl -s http://127.0.0.1:9090/authentication/5g_aka
```

Expected: `{"imsi":"..."}`.

Authentication POST example (`rand` and `autn` must come from your core / AuC):

```bash
curl -s -X POST -H 'Content-Type: application/json' \
  -d '{"rand":"00000000000000000000000000000000","autn":"ec9320c2c2000000e1dd22c1ad3e2d3d"}' \
  http://127.0.0.1:9090/authentication/5g_aka
```

## 5. Troubleshooting

| Symptom | Action |
|---------|--------|
| `deploy.sh` cannot find the archive | Keep `deploy.sh` and `openxg-sim-auth.tar.gz` in the same directory |
| `Service not available` | Run `sudo service pcscd start` (or `systemctl start pcscd`) |
| `Failed to read IMSI` | Reseat the card, confirm USIM, run `pcsc_scan` |
| `Address already in use` | Stop the previous `openxg-sim-auth` process on that port |
