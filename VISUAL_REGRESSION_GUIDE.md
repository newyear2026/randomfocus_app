# Visual Regression Guide

This document defines the minimum baseline for visual regression control.

## Minimum Scope

Track these first:

- Shared state UIs
- Settings screen
- Roulette screen
- Timer screen

## Practical Approach

Use one of these:

1. Golden tests for shared widgets and stable screens
2. Manual screenshot baselines for key screens

## Recommended Capture Sizes

- `320x690`
- `390x844`
- `768x1024`

## Required States

- Default state
- Loading state
- Empty state
- Error state where relevant

## Review Checklist

1. Did a shared token change?
2. Did a shared component change?
3. Did CTA hierarchy change?
4. Did spacing or wrapping shift on small screens?
5. Did icon-only controls lose clarity?
