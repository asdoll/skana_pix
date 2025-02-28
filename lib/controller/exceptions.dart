import '../controller/logging.dart';

class BadResponseException implements Exception {
  final String message;

  BadResponseException(this.message) {
    log.e("Bad Response:$message");
  }

  @override
  String toString() {
    return message;
  }
}

class BadRequestException implements Exception {
  final String message;

  BadRequestException(this.message) {
    log.e("Bad Request:$message");
  }

  @override
  String toString() {
    return message;
  }
}
