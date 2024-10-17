import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_cache_manager/src/web/mime_converter.dart';
import 'package:intl/intl.dart';
import 'package:skana_pix/pixiv_dart_api.dart';

class DioFileService extends FileService {
  final PDio dio;

  DioFileService({PDio? pdio}) : dio = pdio ?? PDio();

  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) async {
    final time =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'+00:00'").format(DateTime.now());
    final hash = md5.convert(utf8.encode(time + BaseClient.hashSalt)).toString();
    var res = await dio.get<ResponseBody>(url,
        options: Options(
            responseType: ResponseType.stream,
            validateStatus: (status) => status != null && status < 500,
            headers: {
              "referer": "https://app-api.pixiv.net/",
              "user-agent": "PixivAndroidApp/5.0.234 (Android 14; skanapix)",
              "x-client-time": time,
              "x-client-hash": hash,
              "accept-enconding": "gzip"
            }));
    if (res.statusCode != 200) {
      throw BadRequestException("Failed to load image: ${res.statusCode}");
    }
    if(res.data == null){
      throw BadResponseException("Failed to load image: empty response");
    }
    return DioResponse(res);
  }
  
}

class DioResponse implements FileServiceResponse {
  final Response<ResponseBody> _response;
  DioResponse(this._response);
  

  @override
  Stream<List<int>> get content => _response.data!.stream;

  @override
  int? get contentLength {
    final contentLengthHeader = _response.headers.value("content-length");
    return contentLengthHeader != null ? int.parse(contentLengthHeader) : null;
  }

  @override
  String? get eTag => _response.headers.value("etag");

  @override
  int get statusCode => _response.statusCode ?? 404;//wont happen

  @override
  DateTime get validTill => DateTime.now().add(const Duration(days: 1));
  
  @override
  String get fileExtension {
    final contentType = _response.headers.value("content-type");
    if (contentType == null) {
      return ".jpeg";
    }
    return ContentType.parse(contentType).fileExtension;
  }
}