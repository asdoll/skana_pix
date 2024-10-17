import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'DioFileService.dart';

class ImagesCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'PixCachedImage';
  ImagesCacheManager():super(
    Config(
      key,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileSystem: IOFileSystem(key),
      fileService: DioFileService(),
  ));
}

ImagesCacheManager imagesCacheManager = ImagesCacheManager();