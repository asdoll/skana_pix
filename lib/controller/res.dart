import 'exceptions.dart' show BadResponseException;


class Res<T>{
  ///error info
  final String? errorMessage;

  String get errMsg => errorMessage??"Unknown Error";

  /// data
  final T? _data;

  /// is there an error
  bool get error => errorMessage!=null || _data==null;

  /// whether succeed
  bool get success => !error;

  /// data
  ///
  /// must be called when no error happened, or it will throw error
  T get data => _data ?? (throw BadResponseException(errMsg));

  /// get data, or null if there is an error
  T? get dataOrNull => _data;

  final dynamic subData;

  @override
  String toString() => _data.toString();

  Res.fromErrorRes(Res another, {this.subData}):
        _data=null,errorMessage=another.errMsg;

  /// network result
  const Res(this._data,{this.errorMessage, this.subData});

  Res.error(dynamic e):errorMessage=e.toString(), _data=null, subData=null;
}