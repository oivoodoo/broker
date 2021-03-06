package broker.input.interfaces;

/**
	A virtual gamepad object consisting of `buttons` and just one `stick`.
**/
interface BasicGamepad<B, M:GenericButtonStatusMap<B>, S:Stick> {
	/**
		Mapping from virtual buttons to their corresponding status.
	**/
	final buttons: M;

	/**
		A virtual analog stick.
	**/
	final stick: S;

	/**
		Updates the status of `this` gamepad.
	**/
	function update(): Void;
}
