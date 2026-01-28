<img src="https://github.com/matheus-s-arruda/Cognite/blob/1.2/thumbnail/capa.png">

[![Generic badge](https://img.shields.io/badge/last_version-4.1.0-red.svg)](https://shields.io/)
[![Generic badge](https://img.shields.io/badge/godot_version-4.5.1.stable-blue.svg)](https://shields.io/)

## install guide
You can acquire Cognite in your project in two ways
- Download the [latest version](https://github.com/matheus-s-arruda/Cognite/releases/tag/v2.0) and extract it into the `addons folder`. (recommended)
- Download directly to your godot 4.5 via [Godot Asset Library](https://godotengine.org/asset-library/asset/2235)
- Clone this repository and add the `cognite folder` to your `addons folder` (if it doesn't exist, create it)

[previous version - Cognite 1.3](https://github.com/matheus-s-arruda/Cognite/blob/3.0/README.md)

# Update 4.0 - Cognite 2
## Complete system reorganization

- The graph system has been removed; the design is now based on scoring.
- All states are active and are decided by a scoring system.
- Scoring is determined by context
- Contexts are defined based on perceptions, observing the world from the CogniteNode.


In summary, CogniteNode triggers Perceptions, Various Perceptions create Contexts, and from these Contexts, Decisions are defined through the impact that each Context has on the Decisions.


<img src="https://github.com/matheus-s-arruda/Cognite/blob/5.1/thumbnail/tunb.png">

## Perceptions

Perceptions are the receivers of the world; they indicate what happens, they don't perform calculations or say how things happen, they only report facts.

<img src="https://github.com/matheus-s-arruda/Cognite/blob/5.1/thumbnail/perceptions.png">

## Contexts

Contexts, as the name suggests, are the abstraction of context from perceptions, from facts that, in turn, are related.

<img src="https://github.com/matheus-s-arruda/Cognite/blob/5.1/thumbnail/context.png">

## Decisions

The key to the functioning and purpose of this system is the Score. Intuitively, the user can articulate how they want decisions to be made, thus having both a way to control priorities and also to create situations where the decision will be influenced by diverse contexts such as the environment, the NPC's mental state, weather conditions, etc.

<img src="https://github.com/matheus-s-arruda/Cognite/blob/5.1/thumbnail/decision.png">


# Dear dev

Decision-making is something completely abstract in relation to how to build a game; it depends and varies according to the game genre and also how Cognite will be used. Because the purpose of this plugin goes far beyond simply creating NPC behavior. You can use this plugin to control bosses that adapt to the scenario, you can use it to control the environment itself, making it responsive to the player, you can even use this plugin to create adaptive puzzles—whatever your creativity allows.
