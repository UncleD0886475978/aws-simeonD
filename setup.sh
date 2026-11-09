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

REPO="aws-simeonD"
OWNER="UncleD0886475978"
URL="https://github.com/${OWNER}/${REPO}.git"
DEST="$HOME/repos/${REPO}"
SERVICES="alb beanstalk crossregion-lb ebs ec2 ecs efs iam rds s3 vpc"

echo "==> Step 1/5: Check prerequisites"
if ! command -v git >/dev/null 2>&1; then
  echo "git not found. Install it: https://git-scm.com/downloads"
  exit 0
fi
echo "git: $(git --version)"
command -v terraform >/dev/null 2>&1 && echo "terraform: $(terraform version | head -n 1)" \
  || echo "terraform not found (only needed if .tf files are present): https://developer.hashicorp.com/terraform/downloads"
command -v shellcheck >/dev/null 2>&1 && echo "shellcheck: present" \
  || echo "shellcheck not found (optional): https://github.com/koalaman/shellcheck#installing"
command -v python3 >/dev/null 2>&1 && echo "python3: present (for YAML/JSON checks)" \
  || echo "python3 not found: https://www.python.org/downloads/"

echo "==> Step 2/5: Get the repo"
if [ -f ".git/config" ] && grep -q "${REPO}" .git/config 2>/dev/null; then
  echo "Already inside a ${REPO} checkout: $(pwd)"
  DEST="$(pwd)"
elif [ -d "${DEST}/.git" ]; then
  echo "Found existing checkout at ${DEST} — pulling"
  git -C "${DEST}" pull --ff-only
else
  echo "Cloning ${URL} into ${DEST}"
  mkdir -p "$HOME/repos"
  git clone "${URL}" "${DEST}"
fi
cd "${DEST}"

echo "==> Step 3/5: Inventory by service directory"
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

echo "==> Step 4/5: Validate what is actually there"
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

echo "==> Step 5/5: Show any READMEs"
FOUND_README=0
for f in $(find . -path ./.git -prune -o -type f -iname 'README*' -print | sort); do
  echo "--- ${f}"; head -n 30 "${f}"; FOUND_README=1
done
[ "${FOUND_README}" = "0" ] && echo "No README files found in the checkout."

echo ""
echo "Next commands:"
echo "  cd ${DEST}"
echo "  ls alb beanstalk crossregion-lb ebs ec2 ecs efs iam rds s3 vpc"
echo "  # If Terraform: cd <service-dir> && terraform init && terraform plan   # plan first, apply costs money"
echo "  # If scripts:    cat <script>.sh   # read before running anything against AWS"
