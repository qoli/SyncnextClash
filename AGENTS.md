# Repository Guidelines

## Project Structure & Module Organization
- `Unbreak-classical.yaml` and `proxy-classical.yaml` are Clash rule lists in YAML format. Each file contains a single `payload:` list with one rule per line.
- `passwall/` contains plain-text domain lists for Passwall: `direct_host` (direct) and `proxy_host` (proxy). Each line is a domain; `#` starts a comment.
- `README.md` documents the published raw URLs. Update it if you add or rename rule files.

## Build, Test, and Development Commands
This repository is data-only; there is no build or runtime.
- Optional sanity checks:
  - `rg -n "example.com"` to find duplicates or confirm entries.
  - `rg -n "^  -" Unbreak-classical.yaml` to confirm YAML rule formatting.

## Coding Style & Naming Conventions
- YAML rule files:
  - Keep `payload:` at the top.
  - Use two-space indentation and one rule per line, e.g. `  - DOMAIN-SUFFIX,example.com` or `  - IP-CIDR,203.0.113.0/24`.
  - Group related rules with adjacent blocks; avoid reordering unrelated sections.
- Passwall lists:
  - One domain per line; comments start with `#`.
  - Keep sections grouped under short comment headers (e.g., `#google`).

## Testing Guidelines
- No automated tests are configured.
- Manually verify syntax by loading updated files into your Clash/Passwall setup and ensuring they parse without errors.

## Commit & Pull Request Guidelines
- Commit messages follow an emoji + type(scope) pattern (from recent history):
  - Example: `✨ feat(proxy): add example.com` or `🔧 chore(direct_host): update domains`.
- PRs should include:
  - A brief description of why the domain/rule is added.
  - The affected files and rule type (direct vs proxy).
  - Source or rationale for the rule (link or short note).
  - Screenshot not required unless you changed documentation rendering.

## Configuration Tips
- Prefer domain-specific rules (`DOMAIN-SUFFIX`, `DOMAIN-KEYWORD`) before broader IP ranges.
- When adding IP ranges, include the smallest CIDR that satisfies the need.
