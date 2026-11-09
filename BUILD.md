# aws-simeonD — BUILD

## One-line install (fresh Ubuntu/Debian VM)

```bash
curl -fsSL https://raw.githubusercontent.com/UncleD0886475978/aws-simeonD/main/setup.sh | bash
```

The script installs its own prerequisites — git/curl via apt, Terraform from the official HashiCorp apt repository, and Python 3 (venv/pip) via apt (shellcheck too, optionally) — then clones the repo and validates what it finds. Alternative (clone-and-run): `git clone https://github.com/UncleD0886475978/aws-simeonD.git && cd aws-simeonD && ./setup.sh`.

- **Repo:** UncleD0886475978/aws-simeonD
- **Visibility:** Not confirmed via API before the rate limit; no description on file. Treated as public in setup.sh's clone URL.
- **What was actually found:** Root contains ONLY 11 directories, no root files and no root README:
  `alb/`, `beanstalk/`, `crossregion-lb/`, `ebs/`, `ec2/`, `ecs/`, `efs/`, `iam/`, `rds/`, `s3/`, `vpc/` — i.e. AWS lab/practice material organised by service (load balancing, Beanstalk, storage, compute, containers, identity, databases, networking).
- **Inspection limit (important):** The CONTENTS of those 11 subdirectories were NOT inspected. Calls after the root listing hit GitHub MCP HTTP 429 (rate limit), which is a hard stop for this run — not retried. File types inside each service folder (Terraform vs CloudFormation vs console screenshots/scripts) are therefore UNVERIFIED, and setup.sh is deliberately written to discover them at run time rather than assert them here.
- **Docs-only:** NO / UNKNOWN — it is a multi-folder AWS working repo, not a single README; whether any folder is docs-only cannot be settled until the rate limit clears and the folders are listed.
- **What setup.sh does:** Bootstraps base tools (git/curl) via apt, uses the current dir if already in a checkout, else clones into `~/repos/aws-simeonD` (pulls if present), then bootstraps terraform (HashiCorp apt repo) and python3/venv/pip (apt) — on non-apt platforms it prints the install URLs and exits — plus shellcheck via apt when available (still optional). Prints a bootstrap summary (installed tools, working copy, one-line reinstall command) at the end. Inventories every file under each of the 11 service dirs, then validates what it actually finds: `.tf` → `terraform init -backend=false` + `terraform validate` ONLY, never apply, with the apply command printed alongside a cost warning; `.yaml`/`.yml` → python YAML parse; `.json` → python JSON parse; `.sh` → shellcheck (if present) + list with usage. Prints the head of any README found. Ends with next commands.
- **Issue it prevents:** Accidentally running `terraform apply` (or an AWS script) and creating billable AWS resources just to "set up" a practice repo — validation is free, apply is not.
