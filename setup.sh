#!/usr/bin/env bash
set -e
# aws-simeonD — AWS lab files by service, as inspected 2026-11-09.
# Root contains ONLY directories (no root README/files):
#   alb  beanstalk  crossregion-lb  ebs  ec2  ecs  efs  iam  rds  s3  vpc
# Subdirectory contents could NOT be enumerated: the GitHub MCP API
# returned HTTP 429 (rate limit) after the root listing, a hard stop.
# So this script DISCOVERS file types at run time instead of assuming:
# Terraform -> init (no backend) + validate ONLY, never apply.
# YAML/JSON -> parse-check. Shell scripts -> shellcheck + list.
# VM BOOTSTRAP: on a fresh Ubuntu/Debian VM this script INSTALLS its own
# prerequisites (git/curl, Terraform, Python) before validating.

REPO="aws-simeonD"
OWNER="UncleD0886475978"
URL="https://github.com/${OWNER}/${REPO}.git"
DEST="$HOME/repos/${REPO}"
SERVICES="alb beanstalk crossregion-lb ebs ec2 ecs efs iam rds s3 vpc"
RUN_ONELINE="curl -fsSL https://raw.githubusercontent.com/${OWNER}/${REPO}/main/setup.sh | bash"

echo "==> Step 1/6: Platform check + base bootstrap (git, curl)"
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    echo "ERROR: this script needs root or sudo to install packages."
    exit 1
  fi
fi
APT=0
if [ "$(uname -s)" = "Linux" ] && command -v apt-get >/dev/null 2>&1; then APT=1; fi
INSTALLED=""
APT_UPDATED=""
note_installed() { INSTALLED="${INSTALLED} $1"; }
apt_update_once() {
  if [ -z "${APT_UPDATED}" ]; then $SUDO apt-get update -y; APT_UPDATED=1; fi
}
apt_install() {
  apt_update_once
  DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y "$@"
}
if [ "${APT}" -eq 1 ]; then
  BASE_PKGS=""
  command -v git >/dev/null 2>&1 || BASE_PKGS="${BASE_PKGS} git"
  command -v curl >/dev/null 2>&1 || BASE_PKGS="${BASE_PKGS} curl"
  [ -f /etc/ssl/certs/ca-certificates.crt ] || BASE_PKGS="${BASE_PKGS} ca-certificates"
  command -v gpg >/dev/null 2>&1 || BASE_PKGS="${BASE_PKGS} gnupg"
  if [ -n "${BASE_PKGS}" ]; then
    echo "    Installing base tools:${BASE_PKGS}"
    # shellcheck disable=SC2086
    apt_install ${BASE_PKGS}
    note_installed "${BASE_PKGS}"
  else
    echo "    Base tools already present (git, curl, ca-certificates, gnupg)."
  fi
else
  echo "    Non-apt platform detected — bootstrap will only CHECK tools and print install guidance."
fi

# --- Per-tool installers ---
install_terraform() {
  if command -v terraform >/dev/null 2>&1; then echo "    terraform: already present ($(terraform version | head -n 1))"; return 0; fi
  [ "${APT}" -eq 1 ] || return 1
  echo "    Installing Terraform from the official HashiCorp apt repository..."
  curl -fsSL https://apt.releases.hashicorp.com/gpg | $SUDO gpg --batch --yes --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "${VERSION_CODENAME}") main" | $SUDO tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
  $SUDO apt-get update -y
  DEBIAN_FRONTEND=noninteractive $SUDO apt-get install -y terraform
  note_installed "terraform"
}
install_python() {
  if command -v python3 >/dev/null 2>&1 && python3 -c "import venv" >/dev/null 2>&1; then echo "    python3 + venv: already present ($(python3 --version))"; return 0; fi
  [ "${APT}" -eq 1 ] || return 1
  echo "    Installing python3, venv and pip..."
  apt_install python3 python3-venv python3-pip
  note_installed "python3"
}
ensure_apt_pkg() { # ensure_apt_pkg <command> <package>
  if command -v "$1" >/dev/null 2>&1; then echo "    $1: already present"; return 0; fi
  [ "${APT}" -eq 1 ] || return 1
  echo "    Installing $2..."
  apt_install "$2"
  note_installed "$2"
}

echo "==> Step 2/6: Get the repo"
if [ -f "$0" ]; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
else
  SCRIPT_DIR="$PWD"
fi
if [ -f ".git/config" ] && grep -q "${REPO}" .git/config 2>/dev/null; then
  echo "Already inside a ${REPO} checkout: $(pwd)"
  DEST="$(pwd)"
elif [ -d "${DEST}/.git" ]; then
  echo "Found existing checkout at ${DEST} — pulling"
  git -C "${DEST}" pull --ff-only
else
  if ! command -v git >/dev/null 2>&1; then
    echo "git not found. Install it: https://git-scm.com/downloads"
    exit 1
  fi
  echo "Cloning ${URL} into ${DEST}"
  mkdir -p "$HOME/repos"
  git clone "${URL}" "${DEST}"
fi
cd "${DEST}"
REPO_DIR="${DEST}"

echo "==> Step 3/6: Bootstrap prerequisites (Terraform, Python; shellcheck optional)"
echo "git: $(git --version)"
MISSING_LIST=""
install_terraform || MISSING_LIST="${MISSING_LIST} terraform(https://developer.hashicorp.com/terraform/install — only needed if .tf files are present)"
install_python || MISSING_LIST="${MISSING_LIST} python3(https://www.python.org/downloads/)"
if [ -n "${MISSING_LIST}" ]; then
  echo "ERROR: could not auto-install on this platform. Missing:${MISSING_LIST}"
  echo "Install the tool(s) manually, then re-run this script."
  exit 1
fi
ensure_apt_pkg shellcheck shellcheck || echo "shellcheck not found (optional): https://github.com/koalaman/shellcheck#installing"

echo "==> Step 4/6: Inventory by service directory"
for d in ${SERVICES}; do
  if [ -d "${d}" ]; then
    echo "--- ${d}/"
    find "${d}" -type f | sort | sed 's/^/    /'
  else
    echo "--- ${d}/ : MISSING"
  fi
done
echo "All files:"
find . -path ./.git -prune -o -type f -print | sort

echo "==> Step 5/6: Validate what is actually there"
TF_DIRS="$(find . -path ./.git -prune -o -type f -name '*.tf' -print | xargs -r -n1 dirname | sort -u)"
if [ -n "${TF_DIRS}" ]; then
  if command -v terraform >/dev/null 2>&1; then
    for d in ${TF_DIRS}; do
      echo "--- Terraform validate (init -backend=false, NO apply): ${d}"
      (cd "${d}" && terraform init -backend=false -input=false && terraform validate)
    done
  else
    echo "Terraform files found in: ${TF_DIRS} — install Terraform to validate (URL above)."
  fi
  echo "WARNING: Never run 'terraform apply' from this script. Apply creates real AWS resources and COSTS MONEY."
  echo "Manual apply (only when you intend to spend):  cd <dir> && terraform plan && terraform apply"
else
  echo "No .tf files found — skipping Terraform validation."
fi

YAML_FILES="$(find . -path ./.git -prune -o -type f \( -name '*.yaml' -o -name '*.yml' \) -print)"
if [ -n "${YAML_FILES}" ] && command -v python3 >/dev/null 2>&1; then
  for f in ${YAML_FILES}; do
    python3 -c "import yaml,sys; yaml.safe_load(open(sys.argv[1])); print('YAML OK:', sys.argv[1])" "${f}" || true
  done
fi
JSON_FILES="$(find . -path ./.git -prune -o -type f -name '*.json' -print)"
if [ -n "${JSON_FILES}" ] && command -v python3 >/dev/null 2>&1; then
  for f in ${JSON_FILES}; do
    python3 -c "import json,sys; json.load(open(sys.argv[1])); print('JSON OK:', sys.argv[1])" "${f}" || true
  done
fi

SH_FILES="$(find . -path ./.git -prune -o -type f -name '*.sh' -print)"
if [ -n "${SH_FILES}" ]; then
  echo "Shell scripts found:"
  for f in ${SH_FILES}; do echo "  ${f} — run with: bash ${f} (read it first)"; done
  if command -v shellcheck >/dev/null 2>&1; then
    for f in ${SH_FILES}; do echo "--- shellcheck ${f}"; shellcheck "${f}" || true; done
  fi
fi

echo "==> Step 6/6: Show any READMEs"
FOUND_README=0
for f in $(find . -path ./.git -prune -o -type f -iname 'README*' -print | sort); do
  echo "--- ${f}"; head -n 30 "${f}"; FOUND_README=1
done
[ "${FOUND_README}" = "0" ] && echo "No README files found in the checkout."

cat <<EOF

=================== BOOTSTRAP SUMMARY ===================
Installed during this run:${INSTALLED:- (nothing — all tools were already present)}
Working copy: ${REPO_DIR}
Next time, set up from scratch on any fresh Ubuntu VM with one line:
  ${RUN_ONELINE}
=========================================================
EOF

echo ""
echo "Next commands:"
echo "  cd ${DEST}"
echo "  ls alb beanstalk crossregion-lb ebs ec2 ecs efs iam rds s3 vpc"
echo "  # If Terraform: cd <service-dir> && terraform init && terraform plan   # plan first, apply costs money"
echo "  # If scripts:    cat <script>.sh   # read before running anything against AWS"
