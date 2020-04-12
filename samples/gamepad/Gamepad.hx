package gamepad;

import broker.input.GamepadBase;
import broker.input.Stick;
import broker.input.heaps.HeapsPadPort;
import broker.input.heaps.HeapsPadMultitap;
import broker.input.heaps.HeapsInputTools;
import broker.input.builtin.simple.Button;
import broker.input.builtin.simple.ButtonStatusMap;

/**
	An example of gamepad implementation.
**/
class Gamepad extends GamepadBase<Button, ButtonStatusMap, Stick> {
	static inline final analogStickThreshold = 0.1;

	final port: HeapsPadPort;
	final updateButtonStatus: () -> Void;
	final moveSpeed: Float;

	public function new(padPortIndex: Int, moveSpeed: Float) {
		super(new ButtonStatusMap(), new Stick());

		this.port = HeapsPadMultitap.ports[padPortIndex];

		final getButtonChecker = HeapsInputTools.createButtonCheckerGenerator(
			GamepadSettings.keyCodeMap,
			GamepadSettings.padButtonCodeMap,
			this.port
		);
		this.updateButtonStatus = this.buttons.createUpdater(getButtonChecker);

		this.moveSpeed = moveSpeed;
	}

	/**
		This example does:
		1. Update `this.buttons` by keyboard and physical gamepad (prepared in `new()`).
		2. Update `this.stick` by D-Pad buttons in `this.buttons`.
		3. If no D-Pad input detected, update `this.stick` by analog stick of physical gamepad.
	**/
	override public function update() {
		// update this.buttons
		updateButtonStatus();

		// reflect: this.buttons => this.stick
		final movedWithDpad = buttons.reflectToStick(stick);
		if (movedWithDpad) {
			stick.multiplyDistance(moveSpeed);
			return;
		}

		// reflect: physical analog stick => this.stick
		port.updateStick(stick);

		if (stick.distance > analogStickThreshold)
			stick.multiplyDistance(moveSpeed);
		else
			stick.reset();
	}
}

class GamepadSettings {
	/**
		Mapping from virtual buttons to `hxd.Key` codes.
	**/
	public static final keyCodeMap: Map<Button, Array<Int>> = [
		A => [hxd.Key.Z],
		B => [hxd.Key.X],
		X => [hxd.Key.SHIFT],
		Y => [hxd.Key.ESCAPE],
		D_LEFT => [hxd.Key.LEFT],
		D_UP => [hxd.Key.UP],
		D_RIGHT => [hxd.Key.RIGHT],
		D_DOWN => [hxd.Key.DOWN]
	];

	/**
		Mapping from virtual buttons to `hxd.Pad` button codes.
	**/
	public static final padButtonCodeMap: Map<Button, Array<Int>> = [
		A => [hxd.Pad.DEFAULT_CONFIG.A],
		B => [hxd.Pad.DEFAULT_CONFIG.B],
		X => [hxd.Pad.DEFAULT_CONFIG.X],
		Y => [hxd.Pad.DEFAULT_CONFIG.Y],
		D_LEFT => [hxd.Pad.DEFAULT_CONFIG.dpadLeft],
		D_UP => [hxd.Pad.DEFAULT_CONFIG.dpadUp],
		D_RIGHT => [hxd.Pad.DEFAULT_CONFIG.dpadRight],
		D_DOWN => [hxd.Pad.DEFAULT_CONFIG.dpadDown]
	];
}