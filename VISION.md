## Android Tweet Shake Vision

Android Tweet Shake is a legacy Android app that signs in with Twitter and
opens a tweet composer when the user shakes the phone.

The repository is useful as a small Fabric/Twitter SDK and accelerometer sample
from an older Android stack.

The goal is to preserve the sample's intent while making authentication,
sensor, and dependency modernization explicit and safe.

The current focus is:

Priority:

- Keep Twitter login and shake-triggered compose behavior understandable
- Avoid committing Twitter keys, Fabric API keys, or signing material
- Preserve the accelerometer threshold behavior until it is tested
- Keep the legacy Gradle and Fabric setup reviewable

Next priorities:

- Replace deprecated Fabric/Twitter SDK usage with maintained APIs if revived
- Add sensor lifecycle handling and shake-threshold tests
- Move any credentials into documented local configuration
- Modernize Gradle, SDK levels, and dependencies in a dedicated pass

Contribution rules:

- One PR = one focused auth, sensor, build, or documentation topic.
- Do not mix SDK migration with user-facing compose behavior unless required.
- Verify shake behavior on hardware when changing sensor logic.
- Keep credential placeholders empty in committed source.

## Security And Privacy

Twitter credentials and user sessions are sensitive. Real keys and secrets must
not be committed, and failures should not expose session details in logs.

Sensor-triggered posting should remain user-confirmed through the tweet
composer; do not add silent posting behavior.

## What We Will Not Merge (For Now)

- Hardcoded Twitter keys, Fabric keys, tokens, or signing files
- Silent tweet posting or background account actions
- Sensor rewrites without hardware verification notes
- Broad dependency migrations bundled with unrelated behavior changes
