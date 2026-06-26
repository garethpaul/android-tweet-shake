# AGENTS.md

## Repository purpose

`garethpaul/android-tweet-shake` is an Android application or sample. Android app - shake to tweet

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `app` - application source or app module
- `build.gradle` - Gradle build configuration
- `gradlew` - checked-in Gradle wrapper

## Development commands

- Install dependencies: no repository-specific install command is documented.
- Full baseline: `/usr/bin/make check`
- Combined verification: `/usr/bin/make verify`
- Lint/static checks: `/usr/bin/make lint`
- Tests: `/usr/bin/make test`
- Portable detector tests: `scripts/test-shake-detector.sh`
- Build: `/usr/bin/make build`
- Android unit tests when the SDK is configured: `./gradlew test`
- Android debug build when the SDK is configured: `./gradlew assembleDebug`
- Run the Make aliases without caller-supplied extra `-f` files or `MAKEFILES`
  when collecting repository validation evidence.
- Caller-supplied later makefiles, including target-specific override
  `SHELL`/`.SHELLFLAGS` assignments and double-colon public recipes, are
  outside the local Make trust boundary. Startup makefiles can execute
  parse-time Make functions before repository rejection.
- Make syntax in an explicit `-f` path is version-sensitive before the repository Makefile loads; GNU Make 3.81 and 4.2.1 execute that syntax before loading the repository Makefile. Use the checkout as the working directory for paths containing literal `$(`.
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Language mix noted in the README: Java (4), shell (1).
- Use the checked-in Gradle wrapper for Android builds when an SDK is configured.

## Testing guidance

- Test-related files detected: `app/src/test/`
- Start with the narrowest relevant test or Make target, then run `/usr/bin/make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- The retired Twitter/Fabric SDK, credential fields, login activity, direct network permission, and package-specific composer must not be restored.
- Shakes open a user-confirmed Android `ACTION_SEND` chooser without querying or forcing a destination package.
- Preserve duplicate-launch suppression, generic unavailable feedback, and lifecycle-safe accelerometer registration and cleanup.
- A sensor registration security rejection must complete registration as failed,
  clear listener ownership, and reuse generic unavailable feedback.
- Missing activities and permission-rejected chooser launches must clear
  duplicate-launch suppression and show the same generic unavailable feedback.
- Queued accelerometer callbacks must be ignored unless the activity is resumed;
  mark it inactive before listener teardown in `onPause`.
- The accelerometer is optional; devices without it must remain usable and show generic unavailable feedback instead of crashing.
- This looks like a legacy Android project or sample. Expect Android SDK, Gradle, and support-library versions to matter.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `/usr/bin/make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
