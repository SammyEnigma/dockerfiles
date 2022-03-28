#!/usr/bin/env bash
set -Eeuo pipefail

[ -e versions.json ]

dir="$(readlink -ve "$BASH_SOURCE")"
dir="$(dirname "$dir")"
source "$dir/../.libs/pypi.sh"

json="$(pypi 'diffoscope')"

jq <<<"$json" -S . > versions.json