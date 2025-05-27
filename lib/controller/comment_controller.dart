import 'package:get/get.dart';
import 'package:skana_pix/controller/connector.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/controller/res.dart';
import 'package:skana_pix/model/comment.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/loading_indicator.dart';

class CommentController extends GetxController {
  String? nextUrl;
  String id;
  ArtworkType type;
  Rx<LoadingState> loadingState = LoadingState.idle.obs;
  RxList<Comment> comments = RxList.empty();
  RxString error = "".obs;
  RxInt parentCommentId = 0.obs;
  RxString parentCommentName = "".obs;
  bool isReply;
  RxMap<int, bool> showMenu = RxMap();

  CommentController(this.id, this.type, this.isReply);

  Future<Res<List<Comment>>> loadData() async {
    if (loadingState.value == LoadingState.loading) return Res(null);
    if (nextUrl == "end") {
      loadingState.value = LoadingState.noMore;
      loadingState.refresh();
      return Res.error("No more data");
    }
    loadingState.value = LoadingState.loading;
    loadingState.refresh();
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
      loadingState.value = LoadingState.noMore;
      loadingState.refresh();
    } else {
      loadingState.value = LoadingState.success;
      loadingState.refresh();
    }
    return res;
  }

  Future<void> nextPage() async {
    if (loadingState.value == LoadingState.loading) return;
    if (loadingState.value == LoadingState.noMore) return;
    var value = await loadData();
    if (value.success) {
      comments.addAll(filterComments(value.data));
      comments.refresh();
      loadingState.value = LoadingState.success;
      loadingState.refresh();
    } else {
      var message = value.errorMessage ??
          "Network Error. Please refresh to try again.".tr;
      if (message == "No more data") {
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      if (message.length > 45) {
        message = "${message.substring(0, 20)}...";
      }
      error.value = message;
      Leader.showToast(message);
      loadingState.value = LoadingState.error;
      loadingState.refresh();
    }
  }

  Future<void> reset() async {
    nextUrl = null;
    loadingState.value = LoadingState.idle;
    comments.clear();
    comments.refresh();
    error.value = "";
    await firstLoad();
  }

  Future<void> firstLoad() async {
    if (loadingState.value == LoadingState.loading) return;
    if (loadingState.value == LoadingState.noMore) return;
    var value = await loadData();
    if (value.success) {
      comments.addAll(filterComments(value.data));
      if (comments.isEmpty) {
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
      }
      comments.refresh();
      loadingState.value = LoadingState.success;
      loadingState.refresh();
    } else {
      var message = value.errorMessage ??
          "Network Error. Please refresh to try again.".tr;
      if (message == "No more data") {
        loadingState.value = LoadingState.noMore;
        loadingState.refresh();
        return;
      }
      if (message.length > 45) {
        message = "${message.substring(0, 20)}...";
      }
      error.value = message;
      Leader.showToast(message);
      loadingState.value = LoadingState.error;
      loadingState.refresh();
    }
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
        reset();
      }
    } else if (type == ArtworkType.NOVEL) {
      res =
          await ConnectManager().apiClient.commentNovel(id, com, parentId: pp);
      if (res.error) {
        Leader.showToast(res.errorMessage ?? "Network Error".tr);
      } else {
        Leader.showToast("Commented".tr);
        reset();
      }
    }
  }
}
