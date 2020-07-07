package broker.object.heaps;

#if heaps
import broker.object.internal.ObjectData;

@:forward(x, y, setPosition, addChild, removeChild, removeChildren)
abstract Object(ObjectData) from ObjectData to ObjectData {
	/**
		`this` as the underlying type.
	**/
	public var data(get, never): ObjectData;

	public extern inline function new() {
		this = new ObjectData();
	}

	/**
		Sets `filter` to `this` object.
	**/
	public extern inline function setFilter(filter: Filter): Void
		this.filter = filter;

	extern inline function get_data()
		return this;
}
#end