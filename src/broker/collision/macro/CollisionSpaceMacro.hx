package broker.collision.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sneaker.types.Maybe;
import sneaker.macro.Types;
import sneaker.macro.ContextTools;
import sneaker.macro.MacroLogger.*;
import broker.collision.cell.PartitionLevel;

using sneaker.macro.extensions.ExprExtension;

class CollisionSpaceMacro {
	public static macro function build(): Null<Fields> {
		final localClassResult = ContextTools.getLocalClassRef();
		if (localClassResult.isFailedWarn()) return null;
		final localClassRef = localClassResult.unwrap();
		final localClass = localClassRef.get();
		final localClassPathString = localClassRef.toString();

		final maybeParameters = getMetadataParameters(localClass);
		if (maybeParameters.isNone()) return null;
		final parameters = maybeParameters.unwrap();

		final leftX = parameters.leftTop.x;
		final topY = parameters.leftTop.y;
		final rightX = parameters.rightBottom.x;
		final bottomY = parameters.rightBottom.y;
		final levelValue = parameters.level;
		final gridSize = 1 << levelValue;
		final leafCellPositionFactorX = gridSize / (rightX - leftX);
		final leafCellPositionFactorY = gridSize / (bottomY - topY);

		final classDef = macro class CollisionSpace {
			/**
				The x coordinate of the left-top point of the entire space.
			**/
			public static final leftX: Float = $v{leftX};

			/**
				The y coordinate of the left-top point of the entire space.
			**/
			public static final topY: Float = $v{topY};

			/**
				The x coordinate of the right-bottom point of the entire space.
			**/
			public static final rightX: Float = $v{rightX};

			/**
				The y coordinate of the right-bottom point of the entire space.
			**/
			public static final bottomY: Float = $v{bottomY};

			/**
				The finest `PartitionLevel` value of `this` space (i.e. the depth of quadtrees).
			**/
			public static var partitionLevel(
				get,
				never
			): broker.collision.cell.PartitionLevel;

			/**
				The size of the space grid determined by `this.partitionLevel`.
			**/
			public static var gridSize(get, never): Int;

			/**
				Factor for calculating the position of a leaf cell
				(i.e. a cell in the finest partition level) in the space grid.
			**/
			public static var leafCellPositionFactorX(get, never): Float;

			/**
				Factor for calculating the position of a leaf cell
				(i.e. a cell in the finest partition level) in the space grid.
			**/
			public static var leafCellPositionFactorY(get, never): Float;

			/**
				@return The local index of the leaf `Cell` that contains the position `x, y`.
			**/
			static inline function getLeafCellLocalIndex(
				x: Float,
				y: Float
			): broker.collision.cell.LocalCellIndex {
				return if (x < leftX || x >= rightX || y < topY || y >= bottomY) {
					broker.collision.cell.LocalCellIndex.none;
				} else {
					inline function toInt(v: Float)
						return banker.type_extension.FloatExtension.toInt(v);

					final cellPositionX = toInt((x - leftX) * leafCellPositionFactorX);
					final cellPositionY = toInt((y - topY) * leafCellPositionFactorY);

					final indexValue = banker.types.Bits.zip(
						banker.types.Bits.from(cellPositionX),
						banker.types.Bits.from(cellPositionY)
					);

					new broker.collision.cell.LocalCellIndex(indexValue.toInt());
				}
			}

			/**
				@return New `Quadtree` with the specified `PartitionLevel`.
			**/
			public static inline function createQuadtree(): broker.collision.Quadtree {
				return new broker.collision.Quadtree(partitionLevel);
			}

			/**
				@return `GlobalCellIndex` of the finest `Cell` that contains the given AABB.
			**/
			public static inline function getCellIndex(
				leftX: Float,
				topY: Float,
				rightX: Float,
				bottomY: Float
			): broker.collision.cell.GlobalCellIndex {
				final leftTop = getLeafCellLocalIndex(leftX, topY);
				final rightBottom = getLeafCellLocalIndex(rightX, bottomY);

				return if (leftTop.isNone() && rightBottom.isNone()) {
					broker.collision.cell.GlobalCellIndex.none;
				} else {
					var aabbLevel: broker.collision.cell.PartitionLevel;
					var aabbLocalIndex: broker.collision.cell.LocalCellIndex;

					if (leftTop == rightBottom) {
						aabbLevel = partitionLevel;
						aabbLocalIndex = leftTop;
					} else {
						aabbLevel = broker.collision.cell.LocalCellIndex.getAabbLevel(
							leftTop,
							rightBottom,
							partitionLevel
						);
						final largerLeafCellIndex = broker.collision.cell.LocalCellIndex.max(
							leftTop,
							rightBottom
						); // For avoiding `-1`
						aabbLocalIndex = largerLeafCellIndex.inRoughLevel(
							partitionLevel,
							aabbLevel
						);
					}

					aabbLocalIndex.toGlobal(aabbLevel);
				}
			}

			static extern inline function get_partitionLevel()
				return new broker.collision.cell.PartitionLevel($v{levelValue});

			static extern inline function get_gridSize()
				return $v{gridSize};

			static extern inline function get_leafCellPositionFactorX()
				return $v{leafCellPositionFactorX};

			static extern inline function get_leafCellPositionFactorY()
				return $v{leafCellPositionFactorY};
		};

		final buildFields = Context.getBuildFields();
		return buildFields.concat(classDef.fields);
	}

	static function validParameterLength(meta: MetadataEntry, validLength: Int): Bool {
		final params = meta.params;
		if (params == null) {
			warn("Missing parameters", meta.pos);
			return false;
		}

		return switch (params.length) {
			case n if (n < validLength):
				warn("Not enough parameters", meta.pos);
				false;
			case n if (n > validLength):
				warn("Too many parameters", meta.pos);
				false;
			default:
				true;
		}
	}

	static function getMetadataParameters(localClass: ClassType): Maybe<{
		leftTop: Point,
		rightBottom: Point,
		level: Int
	}> {
		var leftTop: Maybe<Point> = Maybe.none();
		var rightBottom: Maybe<Point> = Maybe.none();
		var level: Maybe<Int> = Maybe.none();

		for (meta in localClass.meta.get()) {
			final params = meta.params;

			switch meta.name {
				case ':broker.leftTop' | ':broker_leftTop':
					if (!validParameterLength(meta, 2)) return null;
					final xResult = params[0].getFloatLiteralValue();
					if (xResult.isFailedWarn()) return null;
					final yResult = params[1].getFloatLiteralValue();
					if (yResult.isFailedWarn()) return null;
					leftTop = { x: xResult.unwrap(), y: yResult.unwrap() };
				case ':broker.rightBottom' | ':broker_rightBottom':
					if (!validParameterLength(meta, 2)) return null;
					final xResult = params[0].getFloatLiteralValue();
					if (xResult.isFailedWarn()) return null;
					final yResult = params[1].getFloatLiteralValue();
					if (yResult.isFailedWarn()) return null;
					rightBottom = { x: xResult.unwrap(), y: yResult.unwrap() };
				case ':broker.partitionLevel' | ':broker_partitionLevel':
					if (!validParameterLength(meta, 1)) return null;
					final levelResult = params[0].getIntLiteralValue();
					if (levelResult.isFailedWarn()) return null;
					level = levelResult.toMaybe();
				default:
			}
		}

		if (leftTop.isNone()) {
			warn("Missing metadata: @:broker.leftTop");
			return null;
		}

		if (rightBottom.isNone()) {
			warn("Missing metadata: @:broker.rightBottom");
			return null;
		}

		if (level.isNone()) {
			warn("Missing metadata: @:broker.partitionLevel");
			return null;
		}

		return {
			leftTop: leftTop.unwrap(),
			rightBottom: rightBottom.unwrap(),
			level: level.unwrap()
		};
	}
}

private typedef Point = { x: Float, y: Float }
#end