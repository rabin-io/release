#!/bin/bash

set -o errexit
set -o pipefail

# shellcheck disable=SC2155
readonly SCRIPT_FILE=$(readlink -f "${BASH_SOURCE[0]}")
# shellcheck disable=SC2155
# readonly SCRIPT_DIR=$(dirname "${SCRIPT_FILE}")

if [[ -z "${SHARED_DIR:-}" || ! -d "${SHARED_DIR}" ]]; then
    echo "SHARED_DIR is not set or is not a directory"
    exit 1
fi

# Copy self to shared directory
cp "${SCRIPT_FILE}" "${SHARED_DIR}/"

ls -l "${SHARED_DIR}"

### Shared functions

# Get YQ
# Usage:
#        YQ_CMD=$(get::YQ)
#        $YQ_CMD eval ...
#
function get::YQ() {
    # Install yq manually if not found in image
    echo "Checking if yq exists" >&2
    # shellcheck disable=SC2155
    local yq_cmd="$(command -v yq 2>/dev/null || true)"
    if [ -n "${yq_cmd}" ]; then
        echo -n "${yq_cmd}"
        return
    else
        BIN_DIR=$(mktemp -d /tmp/bin.XXXX)
        ARCH=$(uname -m | sed 's/aarch64/arm64/;s/x86_64/amd64/')

        echo "Downloading yq" >&2
        curl --fail -sL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH}" \
         -o "${BIN_DIR}/yq" && chmod +x "${BIN_DIR}/yq"

        export PATH="${BIN_DIR}:${PATH}"
        echo -n "${BIN_DIR}/yq"
    fi
}
