import 'dart:io';
import 'package:archive/archive_io.dart';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:skana_pix/controller/caches.dart';

import 'dart:ui' as ui;

import 'package:skana_pix/controller/connector.dart';


class UgoiraWidget extends StatefulWidget {
  const UgoiraWidget(
      {super.key,
      required this.id,
      required this.previewImage,
      required this.width,
      required this.height});

  final String id;

  final ImageProvider previewImage;

  final double width;

  final double height;

  @override
  State<UgoiraWidget> createState() => _UgoiraWidgetState();
}

class _UgoiraWidgetState extends State<UgoiraWidget> {
  _UgoiraMetadata? _metadata;

  bool _loading = false;

  bool _finished = false;

  bool _error = false;

  int expectedBytes = 1;

  int receivedBytes = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: !_finished
          ? buildPreview()
          : _UgoiraAnimation(
              metadata: _metadata!,
              key: Key(widget.id),
            ),
    );
  }

  Widget buildPreview() {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image(
              image: widget.previewImage,
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (_error)
          const Positioned.fill(
              child: Center(
            child: Icon(
              Icons.error_outline,
              size: 36,
            ),
          )),
        if (!_loading)
          Positioned.fill(
            child: GestureDetector(
              onTap: load,
              child: const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 36,
                ),
              ),
            ),
          )
        else
          Center(
            child: CircularProgressIndicator(
              value: (receivedBytes / expectedBytes) * 100,
            ),
          ),
      ],
    );
  }

  void load() async {
    setState(() {
      _loading = true;
    });
    var res0 = await ConnectManager()
        .apiClient
        .apiGet('/v1/ugoira/metadata?illust_id=${widget.id}');
    if (res0.error) {
      setState(() {
        _error = true;
        _loading = false;
      });
      return;
    }
    var json = res0.data;
    _metadata = _UgoiraMetadata(
      url: json["ugoira_metadata"]["zip_urls"]["medium"],
      frames: (json["ugoira_metadata"]["frames"] as List)
          .map<_UgoiraFrame>((e) => _UgoiraFrame(
                delay: e["delay"],
                fileName: e["file"],
              ))
          .toList(),
    );
    try {
      var cachingFile =
          thisDownloadManager.getFileStream(_metadata!.url, withProgress: true);
      cachingFile.listen((event) async {
        if (event is DownloadProgress) {
          setState(() {
            receivedBytes = event.downloaded;
            expectedBytes = event.totalSize ?? 1;
          });
        } else if (event is FileInfo) {
          await extract(event.file.path);
        }
      });
    } catch (e) {
      setState(() {
        _error = true;
        _loading = false;
      });
      return;
    }
  }

  Future<void> extract(String filePath) async {
    var zip = ZipDecoder().decodeBytes(await File(filePath).readAsBytes());
    for (var file in zip) {
      if (file.isFile) {
        var frame = _metadata!.frames
            .firstWhere((element) => element.fileName == file.name);
        frame.data = await decodeImageFromList(file.content);
      }
    }
    zip.clear();
    setState(() {
      _loading = false;
      _finished = true;
    });
  }
}

class _UgoiraAnimation extends StatefulWidget {
  const _UgoiraAnimation({super.key, required this.metadata});

  final _UgoiraMetadata metadata;

  @override
  State<_UgoiraAnimation> createState() => _UgoiraAnimationState();
}

class _UgoiraAnimationState extends State<_UgoiraAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final totalDuration = widget.metadata.frames.fold<int>(
        0, (previousValue, element) => previousValue + element.delay);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDuration),
      value: 0,
      lowerBound: 0,
      upperBound: widget.metadata.frames.length.toDouble(),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final frame = widget.metadata.frames[_controller.value.toInt()];
        return CustomPaint(
          painter: _ImagePainter(frame.data!),
        );
      },
    );
  }
}

class _UgoiraMetadata {
  final String url;
  final List<_UgoiraFrame> frames;

  _UgoiraMetadata({required this.url, required this.frames});
}

class _UgoiraFrame {
  final int delay;
  final String fileName;
  ui.Image? data;

  _UgoiraFrame({required this.delay, required this.fileName});
}

class _ImagePainter extends CustomPainter {
  final ui.Image data;

  _ImagePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    // 覆盖整个画布
    Rect rect = Offset.zero & size;
    canvas.drawImageRect(
        data,
        Rect.fromLTRB(0, 0, data.width.toDouble(), data.height.toDouble()),
        rect,
        Paint()..filterQuality = FilterQuality.medium);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return data != (oldDelegate as _ImagePainter).data;
  }
}
