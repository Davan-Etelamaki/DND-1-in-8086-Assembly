# Agent configuration (DND-1-in-8086-Assembly)

This repo is a port of DND #1 in 8086 Assembly (bootable, NASM, tests via Make/Node/Playwright). It does **not** use agent_core.

## Workspace rules (workspace = musicman89 directory)

- **industry-practices.mdc** — Applies to all projects: security, DevOps, architecture, coding, testing, documentation. See workspace root `.cursor/rules/industry-practices.mdc`.
- **project-architecture.mdc** — N/A (this project does not use agent_core).

## In-repo rules

- **.cursor/rules/** — Assembly and test conventions, plan-from-requirements, implement-from-plan, log-build, when-debugging-or-fixing. See `.cursor/build-specs/` for component specs.
- **.cursor/skills/** — build-and-test-pipeline, verify-implementation.

## Key references

- **README.md** — Build, run, test (Make, Scripts, Playwright).
- **Documentation/README.md** — Full doc index.
