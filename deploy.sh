#!/usr/bin/env bash
# Install pcscd, extract openxg-sim-auth.tar.gz .
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

if [[ "$(id -u)" -ne 0 ]]; then
	echo "Please run: sudo $0" >&2
	exit 1
fi

ARCHIVE="$DIR/openxg-sim-auth.tar.gz"
if [[ ! -f "$ARCHIVE" ]]; then
	echo "Missing: $ARCHIVE (place deploy.sh beside openxg-sim-auth.tar.gz)" >&2
	exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y pcscd pcsc-tools

if command -v systemctl >/dev/null 2>&1; then
	systemctl enable --now pcscd 2>/dev/null || systemctl start pcscd || true
else
	service pcscd start || true
fi

tar xzf "$ARCHIVE" -C "$DIR"

if [[ ! -x "$DIR/openxg-sim-auth/openxg-sim-auth" ]]; then
	echo "Extract failed or binary missing under $DIR/openxg-sim-auth/" >&2
	exit 1
fi

echo ""
echo "Deploy OK."
echo "  Directory: $DIR/openxg-sim-auth"
echo "  Start:     cd $DIR/openxg-sim-auth && ./openxg-sim-auth --host 0.0.0.0 --port 9090"
echo "  Test:      curl http://127.0.0.1:9090/authentication/5g_aka"
