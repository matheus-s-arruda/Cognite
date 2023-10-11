# Cognite
 Develop State Machines & Behavior Trees with ease and introduce them into your scenes with just one click.


## How to use
> - Add the `CogniteNode` node to your scene, its function is to allow StateMachines to be built in this scene.
> - Create or add a `CogniteAssemble` and start creating your graphs.
<br>

Currently, there are 4 types of nodes.

<img src="https://github.com/matheus-s-arruda/Cognite/blob/main/thumbnail/nodes.png" height="120"/>

<b>The general rule for using nodes is:</b>

The path must always start in a `State`, always end in a `Change State`, at most 1 `Event` node per path and the `Condition` node there is no restriction.
<br><br>

Each node has an important function.

- <b>State</b>: This node is the starting point. In addition to containing a state, you can add another `CogniteAssemble`, this new StateMachine will only be activated if the parent StateMachine is in the state in which this node holds the child StateMachine.
<br>

- <b>Event</b>: Its only function is to activate this path if it receives the named signal. Therefore, there can only be 1 of this node per path, as the path will be triggered as soon as it receives the signal.
<br>

- <b>Condition</b>: This node will observe a Boolean variable and will always maintain a path activated, if there is no `Node Event` in the path, this logic will be processed every frame, you can use several nodes aligned or in parallel with no usage limit.
<br>

- <b>Change State</b>: Its use is simple, change to a new state.
