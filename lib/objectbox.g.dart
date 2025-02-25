// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again
// with `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart' as obx;
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'model/objectbox_models.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
      id: const obx_int.IdUid(1, 3463704868698883050),
      name: 'IllustHistory',
      lastPropertyId: const obx_int.IdUid(7, 2483472823840920638),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 1984458245741936302),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 4607933760072196358),
            name: 'illustId',
            type: 6,
            flags: 8,
            indexId: const obx_int.IdUid(1, 3052419864629376286)),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 6521937257502322384),
            name: 'userId',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 2358193164025649266),
            name: 'pictureUrl',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 5507504946141746117),
            name: 'userName',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 368270718968756168),
            name: 'title',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 2483472823840920638),
            name: 'time',
            type: 6,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(2, 6326380835377129274),
      name: 'NovelHistory',
      lastPropertyId: const obx_int.IdUid(8, 4832103396694345464),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 5710648733776369325),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 6061000690631970721),
            name: 'novelId',
            type: 6,
            flags: 8,
            indexId: const obx_int.IdUid(2, 6370072575861674133)),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 3098610265294301318),
            name: 'userId',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 1024277531089122418),
            name: 'pictureUrl',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 2023810762011068932),
            name: 'time',
            type: 6,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(6, 7486995261077555762),
            name: 'title',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(7, 5885969338935604994),
            name: 'userName',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(8, 4832103396694345464),
            name: 'lastRead',
            type: 6,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[])
];

/// Shortcut for [obx.Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [obx.Store.new] for an explanation of all parameters.
///
/// For Flutter apps, also calls `loadObjectBoxLibraryAndroidCompat()` from
/// the ObjectBox Flutter library to fix loading the native ObjectBox library
/// on Android 6 and older.
Future<obx.Store> openStore(
    {String? directory,
    int? maxDBSizeInKB,
    int? maxDataSizeInKB,
    int? fileMode,
    int? maxReaders,
    bool queriesCaseSensitiveDefault = true,
    String? macosApplicationGroup}) async {
  await loadObjectBoxLibraryAndroidCompat();
  return obx.Store(getObjectBoxModel(),
      directory: directory ?? (await defaultStoreDirectory()).path,
      maxDBSizeInKB: maxDBSizeInKB,
      maxDataSizeInKB: maxDataSizeInKB,
      fileMode: fileMode,
      maxReaders: maxReaders,
      queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
      macosApplicationGroup: macosApplicationGroup);
}

/// Returns the ObjectBox model definition for this project for use with
/// [obx.Store.new].
obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(
      entities: _entities,
      lastEntityId: const obx_int.IdUid(2, 6326380835377129274),
      lastIndexId: const obx_int.IdUid(2, 6370072575861674133),
      lastRelationId: const obx_int.IdUid(0, 0),
      lastSequenceId: const obx_int.IdUid(0, 0),
      retiredEntityUids: const [],
      retiredIndexUids: const [],
      retiredPropertyUids: const [],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, obx_int.EntityDefinition>{
    IllustHistory: obx_int.EntityDefinition<IllustHistory>(
        model: _entities[0],
        toOneRelations: (IllustHistory object) => [],
        toManyRelations: (IllustHistory object) => {},
        getId: (IllustHistory object) => object.id,
        setId: (IllustHistory object, int id) {
          object.id = id;
        },
        objectToFB: (IllustHistory object, fb.Builder fbb) {
          final pictureUrlOffset = fbb.writeString(object.pictureUrl);
          final userNameOffset = object.userName == null
              ? null
              : fbb.writeString(object.userName!);
          final titleOffset =
              object.title == null ? null : fbb.writeString(object.title!);
          fbb.startTable(8);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.illustId);
          fbb.addInt64(2, object.userId);
          fbb.addOffset(3, pictureUrlOffset);
          fbb.addOffset(4, userNameOffset);
          fbb.addOffset(5, titleOffset);
          fbb.addInt64(6, object.time);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final illustIdParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0);
          final userIdParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0);
          final pictureUrlParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 10, '');
          final timeParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 16, 0);
          final titleParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 14);
          final userNameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGetNullable(buffer, rootOffset, 12);
          final object = IllustHistory(
              illustId: illustIdParam,
              userId: userIdParam,
              pictureUrl: pictureUrlParam,
              time: timeParam,
              title: titleParam,
              userName: userNameParam)
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);

          return object;
        }),
    NovelHistory: obx_int.EntityDefinition<NovelHistory>(
        model: _entities[1],
        toOneRelations: (NovelHistory object) => [],
        toManyRelations: (NovelHistory object) => {},
        getId: (NovelHistory object) => object.id,
        setId: (NovelHistory object, int id) {
          object.id = id;
        },
        objectToFB: (NovelHistory object, fb.Builder fbb) {
          final pictureUrlOffset = fbb.writeString(object.pictureUrl);
          final titleOffset = fbb.writeString(object.title);
          final userNameOffset = fbb.writeString(object.userName);
          fbb.startTable(9);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.novelId);
          fbb.addInt64(2, object.userId);
          fbb.addOffset(3, pictureUrlOffset);
          fbb.addInt64(4, object.time);
          fbb.addOffset(5, titleOffset);
          fbb.addOffset(6, userNameOffset);
          fbb.addInt64(7, object.lastRead);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final novelIdParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0);
          final userIdParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0);
          final pictureUrlParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 10, '');
          final timeParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 12, 0);
          final titleParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 14, '');
          final userNameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 16, '');
          final lastReadParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 18, 0);
          final object = NovelHistory(
              novelId: novelIdParam,
              userId: userIdParam,
              pictureUrl: pictureUrlParam,
              time: timeParam,
              title: titleParam,
              userName: userNameParam,
              lastRead: lastReadParam)
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);

          return object;
        })
  };

  return obx_int.ModelDefinition(model, bindings);
}

/// [IllustHistory] entity fields to define ObjectBox queries.
class IllustHistory_ {
  /// See [IllustHistory.id].
  static final id =
      obx.QueryIntegerProperty<IllustHistory>(_entities[0].properties[0]);

  /// See [IllustHistory.illustId].
  static final illustId =
      obx.QueryIntegerProperty<IllustHistory>(_entities[0].properties[1]);

  /// See [IllustHistory.userId].
  static final userId =
      obx.QueryIntegerProperty<IllustHistory>(_entities[0].properties[2]);

  /// See [IllustHistory.pictureUrl].
  static final pictureUrl =
      obx.QueryStringProperty<IllustHistory>(_entities[0].properties[3]);

  /// See [IllustHistory.userName].
  static final userName =
      obx.QueryStringProperty<IllustHistory>(_entities[0].properties[4]);

  /// See [IllustHistory.title].
  static final title =
      obx.QueryStringProperty<IllustHistory>(_entities[0].properties[5]);

  /// See [IllustHistory.time].
  static final time =
      obx.QueryIntegerProperty<IllustHistory>(_entities[0].properties[6]);
}

/// [NovelHistory] entity fields to define ObjectBox queries.
class NovelHistory_ {
  /// See [NovelHistory.id].
  static final id =
      obx.QueryIntegerProperty<NovelHistory>(_entities[1].properties[0]);

  /// See [NovelHistory.novelId].
  static final novelId =
      obx.QueryIntegerProperty<NovelHistory>(_entities[1].properties[1]);

  /// See [NovelHistory.userId].
  static final userId =
      obx.QueryIntegerProperty<NovelHistory>(_entities[1].properties[2]);

  /// See [NovelHistory.pictureUrl].
  static final pictureUrl =
      obx.QueryStringProperty<NovelHistory>(_entities[1].properties[3]);

  /// See [NovelHistory.time].
  static final time =
      obx.QueryIntegerProperty<NovelHistory>(_entities[1].properties[4]);

  /// See [NovelHistory.title].
  static final title =
      obx.QueryStringProperty<NovelHistory>(_entities[1].properties[5]);

  /// See [NovelHistory.userName].
  static final userName =
      obx.QueryStringProperty<NovelHistory>(_entities[1].properties[6]);

  /// See [NovelHistory.lastRead].
  static final lastRead =
      obx.QueryIntegerProperty<NovelHistory>(_entities[1].properties[7]);
}
