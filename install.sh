#!/bin/sh
set -e

if [ -n "$DENOW_DL_BASE_URL" ]; then
  base_url="$DENOW_DL_BASE_URL"
else
  base_url='https://deno.land/x/denow/'
fi

# https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

if command -v curl 2> /dev/null; then
  curl -fsSL "${base_url}denow.bat" -o ./denow.bat
  curl -fsSL "${base_url}denow" -o ./denow
elif command -v wget 2> /dev/null; then
  wget "${base_url}denow.bat" -O ./denow.bat
  wget "${base_url}denow" -O ./denow
else
  echo "Neither 'curl' nor 'wget' found." >&2
  exit 1
fi
chmod +x ./denow

if [ -n "$1" ]; then
  deno_version="$1"
elif command -v grep 2> /dev/null; then
  deno_version=$(get_latest_release denoland/deno | cut -c 2-)
else
  echo "Unable to fetch latest version" >&2
  exit 1
fi

sed -i "s/%__DENO_VERSION__%/$deno_version/g" ./denow.bat
sed -i "s/\$__DENO_VERSION__/$deno_version/g" ./denow

echo "Created wrapper! You can use ./denow to launch Deno."
