# Cognite
 Develop State Machines & Behavior Trees with ease and introduce them into your scenes with just one click.


## How to use
> - Add the `CogniteNode` node to your scene, its function is to allow StateMachines to be built in this scene.
> - Create or add a `CogniteAssemble` and start creating your graphs.
<br>

To generate the MachineState in your scene, go to the CogniteNode node and click `CLICK TO ASSEMBLY` in the inspector.<br>If there is another node created in this way in the scene, this node will be automatically deleted.<br> Remember to save your resources and codes.

---
Currently, there are 4 types of nodes.

<img src="https://github.com/matheus-s-arruda/Cognite/blob/main/thumbnail/nodes.png" height="120"/>
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
- Download directly to your godot 4.2 via [Godot Asset Library](https://godotengine.org/asset-library/asset/2235)
- Download this repository and add the `cognite folder` to your `addons folder` (if it doesn't exist, create it)

<br>

## Examples
Let's try out what logic would be like for an NPC soldier, first let's deduce what he will do and how he will do it:
- He must patrol the region in search of any enemies.
- Regardless of what you are doing, if an enemy is detected, it must enter COMBAT mode.
- If he hears no enemy sightings, he will return to patrol.
- Periodically, he may stop the patrol to eat or go to the bathroom.

Now let's see what this logic would look like using Cognite.





