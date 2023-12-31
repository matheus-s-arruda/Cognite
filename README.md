<img src="https://github.com/matheus-s-arruda/Cognite/blob/1.2/thumbnail/capa.png">

[![Generic badge](https://img.shields.io/badge/last_version-2.0.5-red.svg)](https://shields.io/)
[![Generic badge](https://img.shields.io/badge/godot_version-4.2.stable-blue.svg)](https://shields.io/)

 Develop State Machines & Behavior Trees with ease and introduce them into your scenes with just one click.

[Update 1.1](#update-11)<br>
[Update 1.2](#update-12)<br>
[Update 2.0](#update-20)

## How to use
> - Add the `CogniteNode` node to your scene, its function is to allow StateMachines to be built in this scene.

> - Create or add a `CogniteAssemble`, a `CogniteSource` and start creating your graphs.
<br>

---
### CogniteNode
With this node you can access the state machine and interact with its properties.

### CogniteAssemble
Resource where graph data is saved, you can save it to reuse in other CogniteNodes.

### CogniteSource
Resource for configuring CogniteAssemble, you can reuse it in different CogniteAssemble to create different behaviors using the same data that your scene can access, avoiding the need to edit other scene codes.

---
Currently, there are 4 types of nodes.

<img src="https://github.com/matheus-s-arruda/Cognite/blob/1.1/thumbnail/nodes.png" height="120"/>
<br>

Each node has an important function.

- <b>State</b>: This node is the starting point. In addition to containing a state, you can add another `CogniteAssemble`, this new StateMachine will only be activated if the parent StateMachine is in the state in which this node holds the child StateMachine.
<br>

- <b>Event</b>: Its only function is to activate this path if it receives the named signal. Therefore, there can only be 1 of this node per path, as the path will be triggered as soon as it receives the signal.
<br>

- <b>Condition</b>: This node will observe a Boolean variable and will always maintain a path activated, if there is no `Node Event` in the path, this logic will be processed every frame, you can use several nodes aligned or in parallel with no usage limit.
<br>

- <b>Change State</b>: Its use is simple, change to a new state.
<br>

---
### The general rule for using nodes:
The path must always start in a `State`, always end in a `Change State`, at most 1 `Event` node per path and the `Condition` node there is no restriction.

<br>

## install guide
You can acquire Cognite in your project in two ways
- Download the [latest version](https://github.com/matheus-s-arruda/Cognite/releases/tag/v2.0) and extract it into the `addons folder`. (recommended)
- Download directly to your godot 4.2 via [Godot Asset Library](https://godotengine.org/asset-library/asset/2235)
- Clone this repository and add the `cognite folder` to your `addons folder` (if it doesn't exist, create it)

<br>

## Examples
Let's try out what logic would be like for an NPC soldier, first let's deduce what he will do and how he will do it:
- He must patrol the region in search of any enemies.
- Regardless of what you are doing, if an enemy is detected, it must enter COMBAT mode.
- If he hears no enemy sightings, he will return to patrol.
- Periodically, he may stop the patrol to eat or go to the bathroom.

Now let's see what this logic would look like using Cognite.
<img src="https://github.com/matheus-s-arruda/Cognite/blob/1.1/thumbnail/example.png">
<br>

The first path starts in <b>REST</b>, it will observe 2 conditions in series, this means that it will only change state if the condition is accepted, in this case, the conditions are that the `hunger` and `bathroom` variables are false.

In <b>REST</b> to a second branch, there is already a detected enemy signal.

The first branch of <b>PATROL</b> is the same as that of <b>REST</b>, changing to the <b>COMBAT</b> state if a detected enemy is issued.

The next two branches of <b>PATROL</b> will change to the same state, but with different conditions and in parallel, this means that if one of the two conditions is accepted, the state will be changed.

Lastly we have the <b>COMBAT</b> state, it just waits for the signal of an undetected enemy to return to the <b>PATROL</b> state.

# Update 1.1
## Node Range added
<img src="https://github.com/matheus-s-arruda/Cognite/blob/1.1/thumbnail/range.png">

This node will test a float variable, if it has a value above that specified in "bigger" or "smaller", the respective paths will be activated.

# Update 1.2
## Now on the Main Screen
<img src="https://github.com/matheus-s-arruda/Cognite/blob/1.2/thumbnail/main_screen.png">

The graph editor will now be accessed from the main screen, the operation will remain the same.

## CogniteBehavior
<img src="https://github.com/matheus-s-arruda/Cognite/blob/1.2/thumbnail/behavior.png">

It is now possible to add Resource of type CogniteBehavior to the ROOT node so that it is activated when the respective state is activated.
To correctly use a CogniteBehavior, extend a script and save it in a file, then drag the file to one of the states created in ROOT, the code will be called when the state is activated.

# Update 2.0
## No code generation, everything virtual
Now, the behavior will be built in real time, using `Callable` instead of conversion to GDScript.<br>

Additionally, there is no longer `CogniteBehavior`, there is now a more efficient way to create state blocks.<br>
It is enough that the direct child node of `CogniteNode` has exactly the name of a state.<br>

<img src="https://github.com/matheus-s-arruda/Cognite/blob/2.0/thumbnail/states.png"><br>

The `start()` function will be called when the state is started, the `_process(delta)` and `_physics_process(delta)` functions will **ONLY** be available when the state is activated.<br>

<img src="https://github.com/matheus-s-arruda/Cognite/blob/2.0/thumbnail/funcs.png">

