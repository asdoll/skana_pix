import '../controller/logging.dart';

class BadResponseException implements Exception {
  final String message;

  BadResponseException(this.message) {
    loggerError("Bad Response:$message");
  }

  @override
  String toString() {
    return message;
  }
}

class BadRequestException implements Exception {
  final String message;

  BadRequestException(this.message) {
    loggerError("Bad Request:$message");
  }

  @override
  String toString() {
    return message;
  }
}
