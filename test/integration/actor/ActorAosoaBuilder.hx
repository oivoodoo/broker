package integration.actor;

import banker.common.MathTools.minInt;

typedef ActorAosoaConstructor = (
	chunkCapacity: Int,
	chunkCount: Int,
	batch: h2d.SpriteBatch,
	spriteFactory: () -> h2d.SpriteBatch.BatchElement,
	fireCallback: FireCallback
) -> Void;

typedef ActorAosoaConstructible = haxe.Constraints.Constructible<ActorAosoaConstructor>;

class ActorAosoaBuilder {
	public static var defaultChunkCapacity = 64;

	@:generic
	public static function create<T: ActorAosoaConstructible>(
		maxEntityCount: Int,
		batch: h2d.SpriteBatch,
		fireCallback: FireCallback
	): T {
		final chunkCapacity = minInt(defaultChunkCapacity, maxEntityCount);
		final chunkCount = Math.ceil(maxEntityCount / chunkCapacity);

		final tile = batch.tile;
		final spriteFactory = () -> new h2d.SpriteBatch.BatchElement(tile);
		final aosoa = new T(
			chunkCapacity,
			chunkCount,
			batch,
			spriteFactory,
			fireCallback
		);

		return aosoa;
	}
}