# Test Artifact Policy

This document defines how generated test artifacts should be handled.

## Golden Baselines

- Keep approved golden baselines in `test/goldens/`
- Update them only when UI changes are intentional
- Review updated goldens in the same change as the UI update

## Failure Artifacts

- Treat `test/failures/` as temporary output
- Do not commit failure screenshots or diff images
- Regenerate failures locally only when diagnosing a mismatch

## Git Policy

- Ignore `test/failures/` in version control
- Keep `test/goldens/` tracked

## Review Policy

Before merging UI work:

1. Run `flutter test`
2. Review any changed files in `test/goldens/`
3. Remove `test/failures/` output if it was generated during debugging

## Ownership

- Shared component owners update shared goldens
- Screen-level changes update affected screen goldens
