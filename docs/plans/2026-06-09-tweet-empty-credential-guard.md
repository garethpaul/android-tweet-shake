---
title: Tweet Empty Credential Guard
type: security
status: completed
date: 2026-06-09
---

# Tweet Empty Credential Guard

## Problem Frame

The repository intentionally commits empty Twitter key and secret placeholders.
The activity still constructed `TwitterAuthConfig` and initialized Fabric/Twitter
before any runtime check that credentials were usable.

## Scope Boundaries

- Keep committed Twitter and Fabric credential placeholders empty.
- Preserve the existing Twitter login button flow for configured builds.
- Do not add a credential-loading mechanism or migrate away from Fabric in this
  pass.
- Keep failure feedback generic and resource-backed.

## Implementation Units

### U1: Stop Empty-Key SDK Initialization

Files:

- Modify `app/src/main/java/gpj/tweetshake/MainActivity.java`

Approach:

- Add a small credential-availability helper.
- After layout inflation, show generic unavailable feedback and return when
  either credential placeholder is empty.
- Initialize `TwitterAuthConfig` and Fabric/Twitter only when both values are
  present.

### U2: Cover And Document The Contract

Files:

- Modify `scripts/check-baseline.sh`
- Modify `README.md`
- Modify `VISION.md`
- Modify `CHANGES.md`

Approach:

- Add SDK-free checks for the empty-credential guard.
- Document the local empty-key behavior in project notes.

## Verification

- `scripts/check-baseline.sh`
- `make lint`
- `make test`
- `make build`
- `make check`
- `make verify`
- `git diff --check`
