import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

abstract class LoadingState<T extends StatefulWidget, S extends Object>
    extends State<T> {
  bool isLoading = false;

  S? data;

  String? error;

  Future<Res<S>> loadData();

  Widget buildContent(BuildContext context, S data);

  Widget? buildFrame(BuildContext context, Widget child) => null;

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }

  void retry() {
    setState(() {
      isLoading = true;
      error = null;
    });
    loadData().then((value) {
      if (value.success) {
        setState(() {
          isLoading = false;
          data = value.data;
        });
      } else {
        setState(() {
          isLoading = false;
          error = value.errorMessage!;
        });
      }
    });
  }

  Widget buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error!),
          const SizedBox(height: 12),
          IconButton(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
    ).paddingHorizontal(16);
  }

  @override
  @mustCallSuper
  void initState() {
    isLoading = true;
    loadData().then((value) {
      if (value.success) {
        setState(() {
          isLoading = false;
          data = value.data;
        });
      } else {
        setState(() {
          isLoading = false;
          error = value.errorMessage!;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (isLoading) {
      child = buildLoading();
    } else if (error != null) {
      child = buildError();
    } else {
      child = buildContent(context, data!);
    }

    return buildFrame(context, child) ?? child;
  }
}

abstract class MultiPageLoadingState<T extends StatefulWidget, S extends Object>
    extends State<T> {
  bool _isFirstLoading = true;

  bool _isLoading = false;

  List<S>? _data;

  String? _error;

  int _page = 1;

  String? nexturl;

  Future<Res<List<S>>> loadData(int page);

  Widget? buildFrame(BuildContext context, Widget child) => null;

  Widget buildContent(BuildContext context, List<S> data);

  bool get isLoading => _isLoading || _isFirstLoading;

  bool get isFirstLoading => _isFirstLoading;

  String? get errors => _error;

  List<S>? get datas => _data;

  nextPage() {
    if (_isLoading) return;
    _isLoading = true;
    loadData(_page).then((value) {
      _isLoading = false;
      if (value.success) {
        _page++;
        nexturl = value.subData;
        setState(() {
          _data!.addAll(value.data);
        });
        return true;
      } else {
        var message = value.errorMessage ??
            "Network Error. Please refresh to try again.".i18n;
        if (message == "No more data") {
          return false;
        }
        if (message.length > 45) {
          message = "${message.substring(0, 20)}...";
        }
        BotToast.showText(text: message);
        return false;
      }
    });
  }

  void reset() {
    setState(() {
      _isFirstLoading = true;
      _isLoading = false;
      _data = null;
      _error = null;
      nexturl = null;
      _page = 1;
    });
    firstLoad();
  }

  void firstLoad() {
    nexturl = null;
    loadData(_page).then((value) {
      if (value.success) {
        _page++;
        nexturl = value.subData;
        setState(() {
          _isFirstLoading = false;
          _data = value.data;
        });
      } else {
        setState(() {
          _isFirstLoading = false;
          if (value.errorMessage != null &&
              value.errorMessage!.contains("timeout")) {
            _error = "Network Error. Please refresh to try again.".i18n;
          }
        });
      }
    });
  }

  @override
  void initState() {
    firstLoad();
    super.initState();
  }

  Widget buildLoading(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }

  Widget buildError(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(error),
          const SizedBox(height: 12),
          IconButton(
            onPressed: () {
              reset();
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
    ).paddingHorizontal(16);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_isFirstLoading) {
      child = buildLoading(context);
    } else if (_error != null) {
      child = buildError(context, _error!);
    } else {
      child = buildContent(context, _data!);
    }

    return buildFrame(context, child) ?? child;
  }
}
