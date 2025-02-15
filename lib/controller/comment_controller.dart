import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/connector.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/controller/res.dart';
import 'package:skana_pix/model/comment.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/utils/leaders.dart';

class CommentController extends GetxController {
  String? nextUrl;
  String id;
  ArtworkType type;
  EasyRefreshController? easyRefreshController;
  RxBool isLoading = false.obs;
  RxList<Comment> comments = RxList.empty();
  RxString error = "".obs;
  RxInt parentCommentId = 0.obs;
  RxString parentCommentName = "".obs;
  bool isReply;
  RxMap<int, bool> showMenu = RxMap();

  CommentController(this.id, this.type, this.isReply);

  Future<Res<List<Comment>>> loadData() async {
    if (isLoading.value) return Res.error("Loading");
    if (nextUrl == "end") {
      easyRefreshController?.finishLoad(IndicatorResult.noMore);
      return Res.error("No more data");
    }
    isLoading.value = true;
    Res<List<Comment>> res = type == ArtworkType.NOVEL
        ? (isReply
            ? await ConnectManager()
                .apiClient
                .getNovelCommentsReplies(id, nextUrl)
            : await ConnectManager().apiClient.getNovelComments(id, nextUrl))
        : (isReply
            ? await ConnectManager()
                .apiClient
                .getIllustCommentsReplies(id, nextUrl)
            : await ConnectManager().apiClient.getComments(id, nextUrl));
    if (!res.error) {
      nextUrl = res.subData;
      nextUrl ??= "end";
    }
    if (nextUrl == "end") {
      easyRefreshController?.finishLoad(IndicatorResult.noMore);
    } else {
      easyRefreshController?.finishLoad();
    }
    return res;
  }

  void nextPage() {
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        comments.addAll(filterComments(value.data));
        comments.refresh();
        easyRefreshController?.finishLoad();
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          easyRefreshController?.finishLoad(IndicatorResult.noMore);
          return;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        error.value = message;
        Leader.showToast(message);
        easyRefreshController?.finishLoad(IndicatorResult.fail);
      }
    });
  }

  void reset() {
    nextUrl = null;
    isLoading.value = false;
    comments.clear();
    comments.refresh();
    error.value = "";
    firstLoad();
  }

  void firstLoad() {
    loadData().then((value) {
      isLoading.value = false;
      if (value.success) {
        comments.addAll(filterComments(value.data));
        if (comments.isEmpty) {
          easyRefreshController?.finishRefresh(IndicatorResult.noMore);
        }
        comments.refresh();
        easyRefreshController?.finishRefresh();
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".tr;
        if (message == "No more data") {
          easyRefreshController?.finishRefresh(IndicatorResult.noMore);
          return;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        error = message.obs;
        Leader.showToast(message);
        easyRefreshController?.finishRefresh(IndicatorResult.fail);
      }
    });
  }

  bool commentHateByUser(Comment comment) {
    if (localManager.blockedComments.contains(comment.comment)) {
      return true;
    }
    if (localManager.blockedCommentUsers.contains(comment.name)) {
      return true;
    }
    return false;
  }

  List<Comment> filterComments(List<Comment> comments) {
    return comments.where((element) => !commentHateByUser(element)).toList();
  }

  void submitComment(String com) async {
    Res<bool> res;
    String pp = parentCommentId.value == 0 ? "" : parentCommentId.toString();
    if (type == ArtworkType.ILLUST) {
      res = await ConnectManager().apiClient.comment(id, com, parentId: pp);
      if (res.error) {
        Leader.showToast(res.errorMessage ?? "Network Error".tr);
      } else {
        Leader.showToast("Commented".tr);
        easyRefreshController?.callRefresh();
      }
    } else if (type == ArtworkType.NOVEL) {
      res =
          await ConnectManager().apiClient.commentNovel(id, com, parentId: pp);
      if (res.error) {
        Leader.showToast(res.errorMessage ?? "Network Error".tr);
      } else {
        Leader.showToast("Commented".tr);
        easyRefreshController?.callRefresh();
      }
    }
  }
}
