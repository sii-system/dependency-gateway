#!/bin/sh
set -eu

runtime_dir="${DEPENDENCY_GATEWAY_RUNTIME_CONFIG_DIR:-/etc/dependency-gateway}"
env_file="${DEPENDENCY_GATEWAY_ENV_FILE:-${runtime_dir}/config.local.env}"
mihomo_source="${MIHOMO_CONFIG_FILE:-${runtime_dir}/mihomo.yaml}"
git_plan_source="${DEPENDENCY_GATEWAY_GIT_MIRROR_PLAN:-${runtime_dir}/git-mirror-plan.json}"
download_plan_dir="${DEPENDENCY_GATEWAY_DOWNLOAD_PLAN_DIR:-${runtime_dir}/download-plans}"

if [ ! -r "${env_file}" ]; then
  echo "ERROR: runtime environment file is not readable: ${env_file}" >&2
  exit 1
fi
if [ ! -r "${mihomo_source}" ]; then
  echo "ERROR: mihomo configuration is not readable: ${mihomo_source}" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
. "${env_file}"
set +a

export DEPENDENCY_GATEWAY_STORAGE="${DEPENDENCY_GATEWAY_STORAGE:-s3}"
export DEPENDENCY_GATEWAY_DIR="${DEPENDENCY_GATEWAY_DIR:-/data/dependency-gateway}"
export DEPENDENCY_GATEWAY_UPSTREAM_PROXY="${DEPENDENCY_GATEWAY_UPSTREAM_PROXY:-http://127.0.0.1:7890}"
export DEPENDENCY_GATEWAY_GIT_MIRROR_ROOT="${DEPENDENCY_GATEWAY_GIT_MIRROR_ROOT:-/data/dependency-gateway/github_mirrors}"
gateway_source="${DEPENDENCY_GATEWAY_CONFIG:-${runtime_dir}/sources.json}"

for name in \
  DEPENDENCY_GATEWAY_S3_ENDPOINT \
  DEPENDENCY_GATEWAY_S3_REGION \
  DEPENDENCY_GATEWAY_S3_BUCKET \
  DEPENDENCY_GATEWAY_S3_PREFIX \
  DEPENDENCY_GATEWAY_S3_ACCESS_KEY_ID \
  DEPENDENCY_GATEWAY_S3_SECRET_ACCESS_KEY
do
  eval "value=\${${name}:-}"
  if [ -z "${value}" ]; then
    echo "ERROR: runtime environment is missing ${name}" >&2
    exit 1
  fi
done

if [ ! -r "${gateway_source}" ]; then
  echo "ERROR: Gateway source configuration is not readable: ${gateway_source}" >&2
  exit 1
fi

umask 077
mkdir -p /tmp/dependency-gateway-hosted /tmp/mihomo-home "${DEPENDENCY_GATEWAY_DIR}/tmp"
cp "${mihomo_source}" /tmp/dependency-gateway-hosted/mihomo.yaml
cp "${gateway_source}" /tmp/dependency-gateway-hosted/sources.json
export DEPENDENCY_GATEWAY_CONFIG=/tmp/dependency-gateway-hosted/sources.json
if [ -r "${git_plan_source}" ]; then
  cp "${git_plan_source}" /tmp/dependency-gateway-hosted/git-mirror-plan.json
  export DEPENDENCY_GATEWAY_GIT_MIRROR_PLAN=/tmp/dependency-gateway-hosted/git-mirror-plan.json
else
  unset DEPENDENCY_GATEWAY_GIT_MIRROR_PLAN
fi
if [ -d "${download_plan_dir}" ]; then
  export DEPENDENCY_GATEWAY_DOWNLOAD_PLAN_DIR="${download_plan_dir}"
else
  unset DEPENDENCY_GATEWAY_DOWNLOAD_PLAN_DIR
fi
mkdir -p "${DEPENDENCY_GATEWAY_GIT_MIRROR_ROOT}"
if [ "$(id -u)" -eq 0 ]; then
  chown -R \
    "${DEPENDENCY_GATEWAY_RUNTIME_UID:-10250}:${DEPENDENCY_GATEWAY_RUNTIME_GID:-10250}" \
    /tmp/dependency-gateway-hosted \
    /tmp/mihomo-home \
    "${DEPENDENCY_GATEWAY_DIR}"
fi

exec python /app/deploy/hosted_supervisor.py \
  --mihomo-config /tmp/dependency-gateway-hosted/mihomo.yaml
