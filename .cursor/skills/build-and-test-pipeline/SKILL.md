---
description: >
  Orchestrates the build-and-test workflow for DND-1 8086 Assembly:
  Plan → Implement (assembly + tests + docs) → (Optional) Verify → Log.
alwaysApply: false
---

# Skill: build-and-test-pipeline

────────────────────────────
PURPOSE
────────────────────────────
Single entrypoint for the end-to-end build-and-test pipeline.

This Skill orchestrates:
1) Rule: Plan-From-Requirements (plan from pasted spec or feature + docs)
2) Rule: Implement-From-Plan (implementation: assembly + Test/ + playwright + docs)
3) Skill: verify-implementation (derives AC from spec, creates missing tests, runs tests; optional after implement)
4) Rule: Log-Build (audit log to Documentation/ai-build-log.md)

Rules enforce constraints. This Skill controls flow.

────────────────────────────
ENTRYPOINT
────────────────────────────

RUN_BUILD_PIPELINE

Source (use one):
- Spec: <pasted requirements/spec>  — use when user pastes text or describes a feature
- Feature: <short description>  — use when user asks for a feature without pasted spec; ground in Documentation/ and existing code (for game behavior, include Documentation/DND1-Spec-Web-References.md)
- **(none)**  — when no Spec and no Feature is passed: run in **Validate-all-spec** mode (see below). Validate that the codebase aligns with all in-repo spec docs; derive AC and create missing tests; then log.

Optional:
- VerificationPhase: true | false (default false; in Validate-all-spec mode, verification is always run)
- Scope: <short label for log, e.g. "game flow unit tests">

Documentation/ (including DND1-Spec-Web-References.md for Richard Garriott DND #1), **`.cursor/build-specs/`** (component-level spec: 00-FULL-SCOPE.md and 01–09; see build-specs/README.md), and repo source are the spec.

────────────────────────────
EXECUTION STEPS (when Spec or Feature is provided)
────────────────────────────

1) Plan (Rule)
- Invoke: Plan-From-Requirements
- Inputs: pasted requirements or feature description; use Documentation/, **`.cursor/build-specs/`** (for component-level scope), and existing source as source of truth
- Output: implementation plan (what to change, which files, which tests)

2) Implement (Rule)
- Invoke: Implement-From-Plan
- Provide: plan from step 1; VerificationPhase: <value>

3) Verify (Skill)
- If VerificationPhase == true:
  - Invoke verify-implementation:
    VERIFY_IMPLEMENTATION
    Scope: <Scope or short description>
    Paths: <list of main files changed>

4) Log (Rule)
- Invoke: Log-Build
- Writes to Documentation/ai-build-log.md with Git metadata, what was built, files changed
- Provide: VerificationPhase flag

────────────────────────────
EXECUTION STEPS — Validate-all-spec (when no Spec and no Feature passed)
────────────────────────────

When RUN_BUILD_PIPELINE is invoked with no Spec and no Feature:

1) Skip Plan and Implement for new code. Do not change game/source code except adding tests.
2) Validate all spec:
   - Invoke verify-implementation with **ValidateAllSpec: true**:
     VERIFY_IMPLEMENTATION
     Scope: validate all spec
     Paths: (key implementation areas: SourceFiles/, Test/, playwright/tests/)
     ValidateAllSpec: true
   - The verify-implementation Skill will load all spec docs, derive Acceptance Criteria, create tests for AC that lack coverage, compare codebase with spec, run npm test, and produce a Spec Validation Report.
3) Log (Rule)
   - Invoke: Log-Build
   - In "What was built / changed": "Validate-all-spec run. Acceptance Criteria derived from spec; tests created for AC that had no coverage (see verify-implementation). No other code changes."
   - Include validation summary (specs checked, AC count, tests added, tests pass/fail, gaps if any).

────────────────────────────
NOTES
────────────────────────────
- Documentation/, **`.cursor/build-specs/`** (component specs 00–09), and code are source of truth.
- In-repo game reference spec: Documentation/DND1-Spec-Web-References.md (Richard Garriott DND #1 from web refs). Component-level behavior: .cursor/build-specs/ (README.md, 00-FULL-SCOPE.md, 01–09). Optional web search only if more detail is needed beyond those docs.
- Build log: Documentation/ai-build-log.md (prepend entries; single footer at end).
- Verification creates Acceptance Criteria (Documentation/Acceptance-Criteria.md) from spec and creates tests for any AC that lack coverage (Test/ or Playwright per Testing.md).
