#!/bin/bash
# Update root README.md with module release information

set -euo pipefail

# Arguments from semantic-release
MODULE_NAME="${1}"
MODULE_DISPLAY_NAME="${2}"
TAG_PREFIX="${3}"
VERSION="${4}"
REPO_OWNER="${5}"
REPO_NAME="${6}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ROOT_README="${REPO_ROOT}/README.md"

if [[ ! -f "${ROOT_README}" ]]; then
    echo "Root README.md not found at ${ROOT_README}"
    exit 1
fi

if ! command -v node > /dev/null 2>&1; then
    echo "Node.js is required to update ${ROOT_README}"
    exit 1
fi

echo "Updating root README.md for ${MODULE_NAME} release ${TAG_PREFIX}${VERSION}"

node "${SCRIPT_DIR}/update-readme-indexes.js" \
    --root-only \
    --override-module "${MODULE_NAME}" \
    --override-version "${VERSION}"

sed_in_place() {
    local file="$1"
    shift
    local tmp="${file}.tmp.$$"
    if sed "$@" "${file}" > "${tmp}"; then
        mv "${tmp}" "${file}"
    else
        rm -f "${tmp}"
        return 1
    fi
}

VERSION_TAG="${TAG_PREFIX}${VERSION}"

echo "Updating example module reference"
if grep -q 'source = "github.com/your-org/azurerm-terraform-modules' "${ROOT_README}"; then
    sed_in_place "${ROOT_README}" \
        -e "s|github.com/your-org/azurerm-terraform-modules|github.com/${REPO_OWNER}/${REPO_NAME}|g"
fi

# Update any root README snippets that reference this module's source tag.
sed_in_place "${ROOT_README}" \
    -E \
    -e "s#(source = \"git::https://github.com/${REPO_OWNER}/${REPO_NAME}//modules/${MODULE_NAME}\\?ref=)[^\"]+\"#\\1${VERSION_TAG}\"#g" \
    -e "s#(source = \"https://github.com/${REPO_OWNER}/${REPO_NAME}//modules/${MODULE_NAME}\\?ref=)[^\"]+\"#\\1${VERSION_TAG}\"#g"

echo "Root README.md updated successfully"
