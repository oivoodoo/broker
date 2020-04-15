package broker.collision;

import banker.vector.WritableVector;
import banker.types.Bits;
import broker.collision.cell.*;

using banker.type_extension.FloatExtension;

/**
	Object that represents a 2D space with quadtree space partitioning.
**/
class CollisionSpace {
	/**
		@see `new()`
	**/
	public final width: Int;

	/**
		@see `new()`
	**/
	public final height: Int;

	/**
		@see `new()`
	**/
	public final partitionLevel: PartitionLevel;

	/**
		Vector for using as a stack storing `Collider`s in ancestor `Cell`s when traversing the quadtree.
	**/
	public final ancestorCellColliders: WritableVector<Collider>;

	/**
		Vector for using as a stack for depth-first search in quadtree.
	**/
	public final searchStack: WritableVector<GlobalCellIndex>;

	/**
		Factor for calculating the position of a leaf cell
		(i.e. a cell in the finest partition level) in the space grid.
	**/
	final leafCellPositionFactorX: Float;

	/**
		Factor for calculating the position of a leaf cell
		(i.e. a cell in the finest partition level) in the space grid.
	**/
	final leafCellPositionFactorY: Float;

	/**
		@param width The width of the entire space (i.e. the width of root cell).
		@param height The height of the entire space (i.e. the height of root cell).
		@param partitionLevel The finest `PartitionLevel` value of `this` space (i.e. the depth of quadtrees).
	**/
	public function new(
		width: Int,
		height: Int,
		partitionLevel: Int
	) {
		this.width = width;
		this.height = height;
		this.partitionLevel = new PartitionLevel(partitionLevel);

		final cellCount = this.partitionLevel.totalCellCount();
		this.ancestorCellColliders = new WritableVector(cellCount);
		this.searchStack = new WritableVector(cellCount);

		final gridSize = this.partitionLevel.gridSize();
		this.leafCellPositionFactorX = gridSize / width;
		this.leafCellPositionFactorY = gridSize / height;
	}

	public inline function createCells(): LinearCells {
		return new LinearCells(this.partitionLevel);
	}

	/**
		@return `GlobalCellIndex` of the finest `Cell` that contains the given AABB.
	**/
	public inline function getCellIndex(
		leftX: Float,
		topY: Float,
		rightX: Float,
		bottomY: Float
	): GlobalCellIndex {
		// TODO: early return if index is none
		final leftTop = getLeafCellLocalIndex(leftX, topY);
		final rightBottom = getLeafCellLocalIndex(rightX, bottomY);

		return if (leftTop.isNone() && rightBottom.isNone()) {
			GlobalCellIndex.none;
		} else {
			final partitionLevel = this.partitionLevel;
			var level: PartitionLevel;
			var localIndex: LocalCellIndex;

			if (leftTop == rightBottom) {
				level = partitionLevel;
				localIndex = leftTop;
			} else {
				level = LocalCellIndex.getAabbLevel(leftTop, rightBottom, partitionLevel);
				final largerMorton = LocalCellIndex.max(
					leftTop,
					rightBottom
				); // For avoiding `-1`
				localIndex = largerMorton.inRoughLevel(partitionLevel, level);
			}

			localIndex.toGlobal(level);
		}
	}

	/**
		@return The local index of the leaf `Cell` that contains the position `x, y`.
	**/
	inline function getLeafCellLocalIndex(x: Float, y: Float): LocalCellIndex {
		return if (x < 0 || x > this.width || y < 0 || y > this.height) {
			LocalCellIndex.none;
		} else {
			final cellPositionX = (x * this.leafCellPositionFactorX).toInt();
			final cellPositionY = (y * this.leafCellPositionFactorY).toInt();

			final indexValue = Bits.zip(
				Bits.from(cellPositionX),
				Bits.from(cellPositionY)
			).toInt();

			new LocalCellIndex(indexValue);
		}
	}
}
