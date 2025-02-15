import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'DioFileService.dart';

class ImagesCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'PixCachedImage';
  ImagesCacheManager():super(
    Config(
      key,
      stalePeriod: const Duration(days: 7),
      repo: JsonCacheInfoRepository(databaseName: key),
      fileSystem: IOFileSystem(key),
      fileService: DioFileService(),
  ));
}

class ThisDownloadManager extends CacheManager {
  static const key = 'ThisDownloadManager';
  ThisDownloadManager():super(
    Config(
      key,
      stalePeriod: const Duration(days: 3650),
      repo: JsonCacheInfoRepository(databaseName: key),
      fileSystem: IOFileSystem(key),
      fileService: DioFileService(),
  ));
}

ThisDownloadManager thisDownloadManager = ThisDownloadManager();

ImagesCacheManager imagesCacheManager = ImagesCacheManager();