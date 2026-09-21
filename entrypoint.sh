#!/usr/bin/env bash
set -euo pipefail

# Required inputs
: "${INPUT_HOST:?Missing host}"
: "${INPUT_USERNAME:?Missing username}"
: "${INPUT_PASSWORD:?Missing password}"
: "${INPUT_REMOTE_DIR:?Missing remote_dir}"

# Defaults
: "${INPUT_PROTOCOL:=ftp}"
: "${INPUT_LOCAL_DIR:=.}"
: "${INPUT_DELETE:=false}"
: "${INPUT_DRY_RUN:=false}"
: "${INPUT_ONLY_NEWER:=false}"
: "${INPUT_VERBOSE:=true}"
: "${INPUT_EXCLUDE:=}"

echo "::group::LFTP Deploy to ${INPUT_PROTOCOL}://${INPUT_HOST}${INPUT_REMOTE_DIR}"

# Build lftp command
LFTP_URL="${INPUT_PROTOCOL}://${INPUT_USERNAME}@${INPUT_HOST}"
MIRROR_ARGS="--reverse --verbose"

# Add features
[[ "${INPUT_VERBOSE}" != "true" ]] && MIRROR_ARGS="--quiet"
[[ "${INPUT_DELETE}" == "true" ]] && MIRROR_ARGS="${MIRROR_ARGS} --delete"
[[ "${INPUT_DRY_RUN}" == "true" ]] && MIRROR_ARGS="${MIRROR_ARGS} --dry-run"
[[ "${INPUT_ONLY_NEWER}" == "true" ]] && MIRROR_ARGS="${MIRROR_ARGS} --only-newer"

# Add excludes
if [[ -n "${INPUT_EXCLUDE}" ]]; then
  IFS=',' read -ra EXCLUDES <<< "${INPUT_EXCLUDE}"
  for exclude in "${EXCLUDES[@]}"; do
    MIRROR_ARGS="${MIRROR_ARGS} --exclude-glob ${exclude}"
  done
fi

# Build final command (password hidden)
echo "📤 Syncing ${INPUT_LOCAL_DIR} → ${INPUT_REMOTE_DIR}"
echo "⚙️  Command: lftp -e \"open ${LFTP_URL}; mirror ${MIRROR_ARGS} ${INPUT_LOCAL_DIR} ${INPUT_REMOTE_DIR}; bye\""

# Create temp lftp config to avoid password in process list
LFTP_CONFIG=$(mktemp)
cat > "${LFTP_CONFIG}" << EOF
set ftp:passive-mode yes
set ssl:verify-certificate no
set sftp:auto-confirm yes
open ${INPUT_PROTOCOL}://${INPUT_USERNAME}@${INPUT_HOST}
${INPUT_PASSWORD}
mirror ${MIRROR_ARGS} ${INPUT_LOCAL_DIR} ${INPUT_REMOTE_DIR}
bye
EOF

# Run lftp
lftp -f "${LFTP_CONFIG}"

rm -f "${LFTP_CONFIG}"
echo "::endgroup::"
echo "✅ Deployment complete!"
