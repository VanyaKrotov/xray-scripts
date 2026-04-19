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
	local rc=0
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL --retry 3 --retry-delay 1 "$url" -o "$tmp" || rc=$?
	elif command -v wget >/dev/null 2>&1; then
		wget -q --tries=3 --timeout=10 -O "$tmp" "$url" || rc=$?
	else
		echof "Error: curl or wget required to download files." >&2
		rm -f "$tmp" || true
		return 2
	fi

	if [ "$rc" -ne 0 ]; then
		echof "Download failed (code $rc): $url" >&2
		rm -f "$tmp" || true
		return $rc
	fi

	# Basic validation: non-empty file
	if [ ! -s "$tmp" ]; then
		echof "Downloaded file is empty: $file" >&2
		rm -f "$tmp" || true
		return 4
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

download_file_by_url() {
	local file="$1"
	local url="$2"
	local tmp
	tmp=$(mktemp 2>/dev/null || echo "/tmp/$file.$$")

	echof "Downloading $file from $url..."
	local rc=0
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL --retry 3 --retry-delay 1 "$url" -o "$tmp" || rc=$?
	elif command -v wget >/dev/null 2>&1; then
		wget -q --tries=3 --timeout=10 -O "$tmp" "$url" || rc=$?
	else
		echof "Error: curl or wget required to download files." >&2
		rm -f "$tmp" || true
		return 2
	fi

	if [ "$rc" -ne 0 ]; then
		echof "Download failed (code $rc): $url" >&2
		rm -f "$tmp" || true
		return $rc
	fi

	if [ ! -s "$tmp" ]; then
		echof "Downloaded file is empty: $file" >&2
		rm -f "$tmp" || true
		return 4
	fi

	if ! mkdir -p "$DEST" 2>/dev/null; then
		echof "Creating $DEST requires root — using sudo..."
		if ! command -v sudo >/dev/null 2>&1; then
			echof "Error: cannot create $DEST and sudo is not available." >&2
			rm -f "$tmp" || true
			return 3
		fi
		sudo mkdir -p "$DEST"
	fi

	if ! mv "$tmp" "$DEST/$file" 2>/dev/null; then
		echof "Moving file requires root — using sudo..."
		sudo mv "$tmp" "$DEST/$file"
	fi

	if ! chmod 644 "$DEST/$file" 2>/dev/null; then
		sudo chmod 644 "$DEST/$file" || true
	fi

	echof "Installed: $DEST/$file"
}

main() {
	echof "Resolving latest release via GitHub API..."
	api_url="https://api.github.com/repos/runetfreedom/russia-v2ray-rules-dat/releases/latest"
	if command -v curl >/dev/null 2>&1; then
		json=$(curl -s --fail "$api_url" ) || json=
	elif command -v wget >/dev/null 2>&1; then
		json=$(wget -q -O - "$api_url" 2>/dev/null) || json=
	else
		echof "Error: curl or wget required to query GitHub API." >&2
		exit 2
	fi

	if [ -n "${json:-}" ]; then
		tag=$(printf '%s' "$json" | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name":\s*"([^"]+)".*/\1/')
	else
		tag=
	fi

    echof "Latest release tag (from API): $tag"

	# if [ -z "${tag:-}" ]; then
	# 	echof "Could not determine tag via API, falling back to releases/latest redirect..."
	# 	if command -v curl >/dev/null 2>&1; then
	# 		latest_url=$(curl -sI -o /dev/null -w "%{url_effective}" "$REPO_RELEASES_LATEST")
	# 	elif command -v wget >/dev/null 2>&1; then
	# 		latest_url=$(wget --server-response --max-redirect=0 "$REPO_RELEASES_LATEST" 2>&1 | awk '/Location: /{print $2}' | tail -n1)
	# 	fi
	# 	if [ -n "${latest_url:-}" ] && [ "$latest_url" != "$REPO_RELEASES_LATEST" ]; then
	# 		tag=$(basename "$latest_url")
	# 	else
	# 		echof "Unable to resolve latest release tag." >&2
	# 		exit 2
	# 	fi
	# else
	# 	echof "Latest release tag (from API): $tag"
	# fi

	REPO_DOWNLOAD_BASE="$REPO_BASE/releases/download/$tag"
	for f in "${FILES[@]}"; do
		echof "Resolving asset for '$f'..."
		asset_url=
		if [ -n "${json:-}" ]; then
			# prefer exact name, then case-insensitive contains match
			asset_url=$(printf '%s' "$json" | grep -A5 "\"name\": \"$f\"" | grep '"browser_download_url"' | head -n1 | sed -E 's/.*"browser_download_url":\s*"([^"]+)".*/\1/')
			if [ -z "${asset_url:-}" ]; then
				# fallback: find any asset name containing geoip/geosite (case-insensitive)
				if printf '%s' "$f" | grep -qi geoip; then
					pattern=geoip
				else
					pattern=geosite
				fi
				asset_url=$(printf '%s' "$json" | grep -i -B3 "\"name\": *\"[^"]*${pattern}[^"]*\"" | grep '"browser_download_url"' | head -n1 | sed -E 's/.*"browser_download_url":\s*"([^"]+)".*/\1/')
			fi
		fi

		if [ -n "${asset_url:-}" ]; then
			echof "Found asset URL: $asset_url"
			if ! download_file_by_url "$f" "$asset_url"; then
				echof "Failed to download $f from $asset_url" >&2
				exit 1
			fi
			continue
		fi

		# No direct asset found, try default releases/download/<tag>/<file> and some compressed variants
		tried=0
		for candidate in "$REPO_BASE/releases/download/$tag/$f" "$REPO_BASE/releases/download/$tag/${f}.gz" "$REPO_BASE/releases/download/$tag/${f}.xz"; do
			echof "Trying $candidate"
			tried=$((tried+1))
			if download_file_by_url "$f" "$candidate"; then
				break
			fi
			# if last candidate failed, exit with error
			if [ "$tried" -eq 3 ]; then
				echof "All attempts failed for $f" >&2
				exit 1
			fi
		done
	done
	echof "All files downloaded to $DEST"
}

if [ "${BASH_SOURCE[0]:-$0}" = "$0" ]; then
	main "$@"
fi

