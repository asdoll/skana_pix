import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import 'logging.dart';

class LogInterceptor implements Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log.e(
        "${err.requestOptions.method} ${err.requestOptions.path}\n$err\n${err.response?.data.toString()}");
    switch (err.type) {
      case DioExceptionType.badResponse:
        var statusCode = err.response?.statusCode;
        if (statusCode != null) {
          err = err.copyWith(
              message: "Invalid Status Code: $statusCode. "
                  "${_getStatusCodeInfo(statusCode)}");
        }
      case DioExceptionType.connectionTimeout:
        err = err.copyWith(message: "Connection Timeout");
      case DioExceptionType.receiveTimeout:
        err = err.copyWith(
            message: "Receive Timeout: "
                "This indicates that the server is too busy to respond");
      case DioExceptionType.unknown:
        if (err.toString().contains("Connection terminated during handshake")) {
          err = err.copyWith(
              message: "Connection terminated during handshake: "
                  "This may be caused by the firewall blocking the connection "
                  "or your requests are too frequent.");
        } else if (err.toString().contains("Connection reset by peer")) {
          err = err.copyWith(
              message: "Connection reset by peer: "
                  "The error is unrelated to app, please check your network.");
        }
      default:
        {}
    }
    handler.next(err);
  }

  static const errorMessages = <int, String>{
    400: "The Request is invalid.",
    401: "The Request is unauthorized.",
    403: "No permission to access the resource. Check your account or network.",
    404: "Not found.",
    429: "Too many requests. Please try again later.",
  };

  String _getStatusCodeInfo(int? statusCode) {
    if (statusCode != null && statusCode >= 500) {
      return "This is server-side error, please try again later. "
          "Do not report this issue.";
    } else {
      return errorMessages[statusCode] ?? "";
    }
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    var headers = response.headers.map.map((key, value) => MapEntry(
        key.toLowerCase(), value.length == 1 ? value.first : value.toString()));
    headers.remove("cookie");
    String content;
    if (response.data is List<int>) {
      content = "<Bytes>\nlength:${response.data.length}";
    } else {
      content = response.data.toString();
    }
    String msg =
        "Response ${response.realUri.toString()} ${response.statusCode}\n"
        "headers:\n$headers\n$content";
    if (response.statusCode != null && response.statusCode! < 400) {
      log.i(msg);
    } else {
      log.d(msg);
    }
    handler.next(response);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.connectTimeout = const Duration(seconds: 15);
    options.receiveTimeout = const Duration(seconds: 15);
    options.sendTimeout = const Duration(seconds: 15);

    if (options.headers["Host"] == null && options.headers["host"] == null) {
      options.headers["host"] = options.uri.host;
    }
    log.i(
        "${options.method} ${options.uri}\n${options.headers}\n${options.data}");
    handler.next(options);
  }
}

class PDio extends DioForNative {
  bool isInitialized = false;

  PDio() {
    httpClientAdapter = DomainHttpClientAdapter();
    interceptors.add(LogInterceptor());
  }

  @override
  Future<Response<T>> request<T>(String path,
      {Object? data,
      Map<String, dynamic>? queryParameters,
      CancelToken? cancelToken,
      Options? options,
      ProgressCallback? onSendProgress,
      ProgressCallback? onReceiveProgress}) async {
    if (!isInitialized) {
      isInitialized = true;
      interceptors.add(LogInterceptor());
    }
    if (T == Map<String, dynamic>) {
      var res = await super.request<String>(path,
          data: data,
          queryParameters: queryParameters,
          cancelToken: cancelToken,
          options: options,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);
      if (res.data == null) {
        return Response(
            data: null,
            requestOptions: res.requestOptions,
            statusCode: res.statusCode,
            statusMessage: res.statusMessage,
            isRedirect: res.isRedirect,
            redirects: res.redirects,
            extra: res.extra,
            headers: res.headers);
      }
      try {
        var json = jsonDecode(res.data!);
        return Response(
            data: json,
            requestOptions: res.requestOptions,
            statusCode: res.statusCode,
            statusMessage: res.statusMessage,
            isRedirect: res.isRedirect,
            redirects: res.redirects,
            extra: res.extra,
            headers: res.headers);
      } catch (e) {
        var data = res.data!;
        if (data.length > 50) {
          data = "${data.substring(0, 50)}...";
        }
        throw "Failed to decode response: $e\n$data";
      }
    }
    return super.request<T>(path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress);
  }
}

class DomainHttpClientAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  final Map<String, dynamic> constMap = {
    "app-api.pixiv.net": "210.140.131.199",
    "oauth.secure.pixiv.net": "210.140.131.219",
    "i.pximg.net": "210.140.92.149",
    "s.pximg.net": "210.140.92.143",
    "doh": "doh.dns.sb",
  };

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    Uri uri = options.uri;
    if (constMap.containsKey(uri.host)) {
      String host = options.uri.host;
      String ipAddress = await resolveHostToIp(host);
      int port = options.uri.port;
      String scheme = options.uri.scheme;
      String newPath =
          '$scheme://$ipAddress:$port${options.uri.path}${options.uri.query}';
      options.baseUrl = newPath;
      options.path = "";
    }
    final HttpClient httpClient = HttpClient();
    final HttpClientRequest request =
        await httpClient.openUrl(options.method, uri);
    options.headers.forEach((key, value) {
      request.headers.set(key, value);
    });
    if (requestStream != null) {
      await requestStream.forEach(request.add);
    }
    final HttpClientResponse response = await request.close();
    final List<int> responseBody =
        await response.fold([], (List<int> a, List<int> b) => a..addAll(b));
    return ResponseBody.fromBytes(responseBody, response.statusCode,
        headers: convertHeaders(response.headers),
        statusMessage: response.reasonPhrase);
  }

  Map<String, List<String>> convertHeaders(HttpHeaders headers) {
    Map<String, List<String>> result = {};
    headers.forEach((key, value) {
      result[key] = value;
    });
    return result;
  }

  Future<String> resolveHostToIp(String host) async {
    if (constMap.containsKey(host)) {
      return constMap[host]!;
    }
    return host;
  }
}

void setSystemProxy() {
  HttpOverrides.global = _ProxyHttpOverrides()..findProxy(Uri());
}

class _ProxyHttpOverrides extends HttpOverrides {
  String proxy = "DIRECT";

  String findProxy(Uri uri) {
    //   var haveUserProxy = appdata.settings["proxy"] != null &&
    //       appdata.settings["proxy"].toString().removeAllBlank.isNotEmpty;
    //   if (!App.isLinux && !haveUserProxy) {
    //     var channel = const MethodChannel("pixes/proxy");
    //     channel.invokeMethod("getProxy").then((value) {
    //       if (value.toString().toLowerCase() == "no proxy") {
    //         proxy = "DIRECT";
    //       } else {
    //         if (proxy.contains("https")) {
    //           var proxies = value.split(";");
    //           for (String proxy in proxies) {
    //             proxy = proxy.removeAllBlank;
    //             if (proxy.startsWith('https=')) {
    //               value = proxy.substring(6);
    //             }
    //           }
    //         }
    //         proxy = "PROXY $value";
    //       }
    //     });
    //   } else {
    //     if (haveUserProxy) {
    //       proxy = "PROXY ${appdata.settings["proxy"]}";
    //     }
    //   }
    //   // check validation
    //   if (proxy.startsWith("PROXY")) {
    //     var uri = proxy.replaceFirst("PROXY", "").removeAllBlank;
    //     if (!uri.startsWith("http")) {
    //       uri += "http://";
    //     }
    //     if (!uri.isURL) {
    //       return "DIRECT";
    //     }
    //   }
    return proxy;
  }

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    client.connectionTimeout = const Duration(seconds: 5);
    client.findProxy = findProxy;
    return client;
  }
}
