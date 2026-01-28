<img src="https://github.com/matheus-s-arruda/Cognite/blob/1.2/thumbnail/capa.png">

[![Generic badge](https://img.shields.io/badge/last_version-4.1.0-red.svg)](https://shields.io/)
[![Generic badge](https://img.shields.io/badge/godot_version-4.5.1.stable-blue.svg)](https://shields.io/)

## install guide
You can acquire Cognite in your project in two ways
- Download the [latest version](https://github.com/matheus-s-arruda/Cognite/releases/tag/v2.0) and extract it into the `addons folder`. (recommended)
- Download directly to your godot 4.5 via [Godot Asset Library](https://godotengine.org/asset-library/asset/2235)
- Clone this repository and add the `cognite folder` to your `addons folder` (if it doesn't exist, create it)

# Update 4.0
## Complete system reorganization
- The graph system has been removed; the design is now based on scoring.
- All states are active and are decided by a scoring system.
- Scoring is determined by context
- Contexts are defined based on perceptions, observing the world from the CogniteNode.

