package broker.image.heaps;

import broker.image.common.ImageData as ImageDataBase;

/**
	Bitmap data with some additional information.
**/
@:notNull @:forward
abstract ImageData(ImageDataBase) from ImageDataBase {
	@:from static function fromImage(image: hxd.res.Image): ImageData {
		final pixels = image.getPixels();
		final parsed = Tools.parseImageFileName(image.name);

		return {
			bitmap: pixels,
			name: parsed.name,
			frameSize: parsed.frameSize,
			centerPivot: true
		};
	}
}