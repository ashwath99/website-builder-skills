# Security Policy

## Scope

Website Builder Skills is a collection of markdown instruction files for AI agents. It does not include executable server code, authentication systems, or user data storage. However, we take the integrity of the skill files and any associated tooling seriously.

## Supported Versions


| Version | Supported |
| ------- | --------- |
| 5.3.x   | Yes       |
| 5.0–5.2 | Yes       |
| 4.0.x   | No        |
| < 4.0   | No        |


## Reporting a Vulnerability

If you discover a security issue (e.g., a prompt injection pattern in a skill file, a misconfigured workflow that could leak credentials, or a supply-chain concern in dependencies), please report it responsibly:

1. **Do not** open a public issue.
2. **Email** the maintainer or use [GitHub's private vulnerability reporting](https://github.com/ashwath99/website-builder-skills/security/advisories/new).
3. Include a clear description of the issue, steps to reproduce, and potential impact.

We will acknowledge receipt within 72 hours and aim to provide a fix or mitigation plan within 7 days.

## Best Practices for Users

- Review `design-tokens/token-values.md` token values before deploying generated code to production.
- Do not commit API keys, secrets, or `.env` files to forks of this repository.
- Keep your Figma MCP plugin and AI agent tooling up to date.

