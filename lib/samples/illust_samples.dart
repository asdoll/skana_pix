import '../pixiv_dart_api.dart';

Future<List<Illust>> getIllustSamples() async {
  var account = await Account.fromPath();
  var apiClient = ApiClient(account!, PDio());
  var res = await apiClient.getUserIllusts("35082639", "manga");
  if (res.success) {
    return res.data;
  } else {
    return [];
  }
}
