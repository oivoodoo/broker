package broker.scene;

import broker.timer.Timers;
import broker.color.ArgbColor;

/**
	Game scene object.
**/
interface Scene {
	/**
		The stack to which `this` belongs.
	**/
	var sceneStack: Maybe<SceneStack>;

	/**
		Background layer.
	**/
	final background: Layer;

	/**
		Main layer.
	**/
	final mainLayer: Layer;

	/**
		Surface layer.
	**/
	final surface: Layer;

	/**
		Timers attached to `this` scene.
	**/
	final timers: Timers;

	/**
		@return The type id of `this`.
	**/
	function getTypeId(): SceneTypeId;

	/**
		Called when `this.activate()` is called for the first time.
	**/
	function initialize(): Void;

	/**
		Updates `this` scene.
	**/
	function update(): Void;

	/**
		Called when `this` scene becomes the top in the scene stack.
	**/
	function activate(): Void;

	/**
		Called when `this` scene is no more the top in the scene stack but is not immediately destroyed.
	**/
	function deactivate(): Void;

	/**
		Destroys `this` scene.
	**/
	function destroy(): Void;

	/**
		Starts fade-in effect.
		@param color The starting color.
		@param duration The duration frame count.
	**/
	function fadeInFrom(color: ArgbColor, duration: Int): Void;

	/**
		Starts fade-out effect.
		@param color The ending color.
		@param duration The duration frame count.
	**/
	function fadeOutTo(color: ArgbColor, duration: Int): Void;

	/**
		Switches to the next scene.
		@param duration The delay duration frame count.
	**/
	function switchTo(nextScene: Scene, duration: Int, destroy: Bool): Void;
}
