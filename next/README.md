# Last Call: Night Shift — new rewrite

This directory is a clean first-person mobile rewrite. It does not load or patch the previous `game/`, `mobile/`, `rewrite/`, or `first-person/` implementations.

Runtime: Babylon.js (Apache-2.0), loaded from the Babylon CDN.
All hotel scene layout, interaction flow, HUD, mobile input, guest routing, and game-specific logic in this directory are new project code.

The build is designed around a compact mobile scene, hardware-scaled rendering, first-person collision/gravity, touch joystick movement, touch look, and waypoint-based guest movement.
