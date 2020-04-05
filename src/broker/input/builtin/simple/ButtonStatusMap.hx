package broker.input.builtin.simple;

using banker.type_extension.MapExtension;

import banker.vector.Vector;
import broker.input.ButtonStatus;
import broker.input.heaps.HeapsKeyTools;
import broker.input.heaps.HeapsPadTools;
import broker.input.heaps.HeapsPadSocket;
import broker.input.interfaces.GenericButtonStatusMap;

/**
	Mapping from values of `broker.input.builtin.simple.Button`
	to their corresponding status.
**/
@:build(banker.finite.FiniteKeys.from(Button))
@:banker_verified
@:banker_final
class ButtonStatusMap implements GenericButtonStatusMap<Button> {
	/**
		@param getButtonChecker Function that returns a button checker, which is
		another function that returns `true` if `button` should be considered pressed.
		@return New `ButtonStatusMap` instance.
	**/
	public static function create(
		getButtonChecker: (button: Button) -> (() -> Bool)
	): ButtonStatusMap {
		getButtonCheckerFunction = getButtonChecker;
		final statusMap = new ButtonStatusMap();
		getButtonCheckerFunction = getButtonCheckerDummy;

		return statusMap;
	}

	#if heaps
	/**
		@param keyCodeMap Mapping between Buttons and key codes in `hxd.Key`.
		@return New `ButtonStatusMap` instance.
	**/
	public static function createFromHeapsCodeMap(
		keyCodeMap: Map<Button, Array<Int>>,
		padSocket: HeapsPadSocket,
		padButtonCodeMap: Map<Button, Array<Int>>
	): ButtonStatusMap {
		final getButtonChecker = function(button: Button) {
			final keyCodes = keyCodeMap.getOr(button, []);
			final keyCodesChecker = HeapsKeyTools.createKeyCodesChecker(keyCodes);
			final padButtonCodes = padButtonCodeMap.getOr(button, []);
			final padButtonCodesChecker = HeapsPadTools.createButtonCodesChecker(padSocket, padButtonCodes);
			return () -> keyCodesChecker() || padButtonCodesChecker();
		};
		return create(getButtonChecker);
	}
	#end

	/**
		Internal null object for `getButtonCheckerFunction`.
	**/
	static final getButtonCheckerDummy = function(button: Button): () -> Bool {
		throw "getButtonCheckerFunction() is not set. This code should not be reached.";
	}

	/**
		Internally used in `initialValue()`.
		Is set and reset every time `create()` is called.
	**/
	static var getButtonCheckerFunction = getButtonCheckerDummy;

	/**
		Function for initializing each variable.
		@see `FiniteKeys` of `banker` library.
	**/
	static function initialValue(button: Button): ButtonStatus {
		final buttonIsDown = getButtonCheckerFunction(button);

		return new ButtonStatus(buttonIsDown);
	}

	private function new() {}
}
