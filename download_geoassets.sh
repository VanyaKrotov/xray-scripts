#!/bin/bash
set -euo pipefail

REPO_RELEASES_LATEST="https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest"
REPO_BASE="https://github.com/runetfreedom/russia-v2ray-rules-dat"
FILES=("geoip.dat" "geosite.dat")
DEST="/usr/local/share/xray"

echof() { printf '%s\n' "$*"; }

download_file() {
	local file="$1"
	local url="$REPO_DOWNLOAD_BASE/$file"
	local tmp
	tmp=$(mktemp 2>/dev/null || echo "/tmp/$file.$$")

	echof "Downloading $file from $url..."
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL --retry 3 --retry-delay 1 "$url" -o "$tmp"
	elif command -v wget >/dev/null 2>&1; then
		wget -q --tries=3 --timeout=10 -O "$tmp" "$url"
	else
		echof "Error: curl or wget required to download files." >&2
		rm -f "$tmp" || true
		return 2
	fi

	# Ensure destination exists (try without sudo, fall back to sudo)
	if ! mkdir -p "$DEST" 2>/dev/null; then
		echof "Creating $DEST requires root — using sudo..."
		if ! command -v sudo >/dev/null 2>&1; then
			echof "Error: cannot create $DEST and sudo is not available." >&2
			rm -f "$tmp" || true
			return 3
		fi
		sudo mkdir -p "$DEST"
	fi

	# Move into place (use sudo if needed)
	if ! mv "$tmp" "$DEST/$file" 2>/dev/null; then
		echof "Moving file requires root — using sudo..."
		sudo mv "$tmp" "$DEST/$file"
	fi

	# Set permissions (try without sudo first)
	if ! chmod 644 "$DEST/$file" 2>/dev/null; then
		sudo chmod 644 "$DEST/$file" || true
	fi

	echof "Installed: $DEST/$file"
}

main() {
	echof "Resolving latest release tag from $REPO_RELEASES_LATEST..."
	if command -v curl >/dev/null 2>&1; then
		latest_url=$(curl -sI -o /dev/null -w "%{url_effective}" "$REPO_RELEASES_LATEST")
	elif command -v wget >/dev/null 2>&1; then
		latest_url=$(wget --server-response --max-redirect=0 "$REPO_RELEASES_LATEST" 2>&1 | awk '/Location: /{print $2}' | tail -n1)
	else
		echof "Error: curl or wget required to resolve latest release." >&2
		exit 2
	fi

	if [ -z "${latest_url:-}" ]; then
		echof "Could not determine latest release URL." >&2
		exit 2
	fi

	tag=$(basename "$latest_url")
	REPO_DOWNLOAD_BASE="$REPO_BASE/releases/download/$tag"
	echof "Latest release tag: $tag"
	for f in "${FILES[@]}"; do
		if ! download_file "$f"; then
			echof "Failed to download $f" >&2
			exit 1
		fi
	done
	echof "All files downloaded to $DEST"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	main "$@"
fi

