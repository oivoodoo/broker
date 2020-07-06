package broker.image.heaps;

import haxe.ds.StringMap;
import h3d.mat.Texture;
import broker.image.common.Atlas as AtlasBase;

class Atlas extends AtlasBase {
	/**
		Creates an `Atlas` instance from `imageDataList`.
		@param imageDataList Enum, either `Vertical`, `Horizontal` or `Unit`.
	**/
	public static function from(imageDataList: ImageDataList): Atlas {
		final entireSize = imageDataList.getBoundSize();
		final entireBitmap = new Bitmap(entireSize.width, entireSize.height);
		final frameTilesBuilderMap = new StringMap<(texture: Texture) -> FrameTiles>();

		processImageDataList(
			imageDataList,
			UInt.zero,
			UInt.zero,
			entireBitmap,
			frameTilesBuilderMap
		);

		final texture = Texture.fromPixels(entireBitmap);
		final frameTilesMap = new StringMap<FrameTiles>();
		for (name => build in frameTilesBuilderMap)
			frameTilesMap.set(name, build(texture));

		return new Atlas(frameTilesMap, texture);
	}

	private static function processImageDataList(
		imageDataList: ImageDataList,
		destX: UInt,
		destY: UInt,
		entireBitmap: Bitmap,
		frameTilesBuilderMap: StringMap<(texture: Texture) -> FrameTiles>
	): { width: UInt, height: UInt} {
		switch imageDataList {
			case Vertical(elements):
				var width = UInt.zero;
				var height = UInt.zero;
				for (element in elements) {
					final size = processImageDataList(
						element,
						destX,
						destY,
						entireBitmap,
						frameTilesBuilderMap
					);
					if (width < size.width) width = size.width;
					height += size.height;
					destY += size.height;
				}
				return { width: width, height: height };
			case Horizontal(elements):
				var width = UInt.zero;
				var height = UInt.zero;
				for (element in elements) {
					final size = processImageDataList(
						element,
						destX,
						destY,
						entireBitmap,
						frameTilesBuilderMap
					);
					width += size.width;
					if (height < size.height) height = size.height;
					destX += size.width;
				}
				return { width: width, height: height };
			case Unit(data):
				final srcBitmap = data.bitmap;
				final width = srcBitmap.width;
				final height = srcBitmap.height;
				Bitmap.blit(srcBitmap, 0, 0, entireBitmap, destX, destY, width, height);
				srcBitmap.dispose();
				frameTilesBuilderMap.set(
					data.name,
					(texture) -> broker.image.heaps.FrameTiles.fromData(
						texture,
						destX,
						destY,
						width,
						height,
						data.frameSize,
						data.centerPivot
					)
				);
				return { width: width, height: height };
		}
	}

	public final texture: Texture;

	public function new(frameTilesMap: StringMap<FrameTiles>, texture: Texture) {
		super(frameTilesMap);
		this.texture = texture;
	}
}