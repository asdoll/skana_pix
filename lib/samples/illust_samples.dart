
import 'package:skana_pix/controller/PDio.dart';
import 'package:skana_pix/controller/api_client.dart';
import 'package:skana_pix/model/illust.dart';
import 'package:skana_pix/model/user.dart';

Future<List<Illust>> getIllustSamples() async {
  var account = await Account.fromPath();
  var apiClient = ApiClient(account!, PDio());
  var res = await apiClient.getUserIllusts("123407604", "manga");
  if (res.success) {
    return res.data;
  } else {
    return [];
  }
}
