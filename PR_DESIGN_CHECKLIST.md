# PR Design Checklist

Use this checklist for UI-related pull requests.

## Shared System

- [ ] I checked existing tokens before adding new hard-coded values
- [ ] I checked shared widgets before creating page-local decoration
- [ ] If I added a new shared pattern, I updated the related docs

## States

- [ ] Loading state is defined where async work happens
- [ ] Empty state is defined where data can be absent
- [ ] Error state provides a recovery action where possible
- [ ] Confirmation UI is explicit for destructive or disruptive actions

## Writing

- [ ] Button labels are explicit
- [ ] Error copy is short and actionable
- [ ] Empty-state copy explains what to do next
- [ ] New UI copy follows `UI_WRITING_GUIDE.md`

## Accessibility

- [ ] Icon-only actions have tooltip or semantics labels
- [ ] Primary interactions remain usable at larger text scales
- [ ] Important meaning does not depend on color alone
- [ ] Tap targets remain comfortably touchable

## Responsive

- [ ] Screen works at small phone width
- [ ] Screen works at standard phone width
- [ ] Screen works at tablet width if relevant
- [ ] Long labels or translated strings do not clip badly

## Visual Regression

- [ ] Shared visual components are covered by baseline screenshots or goldens
- [ ] I checked layout shifts on the main affected screens
- [ ] If visuals changed intentionally, I updated the baseline artifacts

## Test Artifacts

- [ ] I reviewed `TEST_ARTIFACT_POLICY.md`
- [ ] I did not commit `test/failures/` artifacts
