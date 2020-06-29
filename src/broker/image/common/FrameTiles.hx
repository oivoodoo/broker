package broker.image.common;

class FrameTiles {
	/**
		The entire tile from which `frames` are created.
	**/
	public final entire: Tile;

	/**
		Sub-tiles divided from the `entire` tile.
	**/
	public final frames: Vector<Tile>;

	function new(entire: Tile, frames: Vector<Tile>) {
		this.entire = entire;
		this.frames = frames;
	}
}
