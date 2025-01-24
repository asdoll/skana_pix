import 'dart:io';

import 'package:flutter/material.dart' show BottomAppBar;
import 'package:path/path.dart' as path;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/leaders.dart';
import '../controller/caches.dart';
import 'pixivimage.dart';

import 'package:share_plus/share_plus.dart';

class ImagePage extends StatefulWidget {
  const ImagePage(this.urls, {this.initialPage = 0, super.key});

  final List<String> urls;

  final int initialPage;

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  @override
  void initState() {
    nowUrl = widget.urls.first;
    super.initState();
  }

  @override
  void dispose() {
    if (_fullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    }
    super.dispose();
  }

  late var controller = PageController(initialPage: widget.initialPage);

  late int currentPage = widget.initialPage;

  bool show = false;
  bool shareShow = false;
  String nowUrl = "";

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (widget.urls.length == 1) {
        final url = widget.urls.first;
        return Scaffold(
          backgroundColor: Colors.black,
          footers: [_buildBottom(context)],
          child: PhotoView(
            filterQuality: FilterQuality.high,
            initialScale: PhotoViewComputedScale.contained,
            heroAttributes: PhotoViewHeroAttributes(tag: url),
            imageProvider: PixivProvider.url(url),
            loadingBuilder: (context, event) => _buildLoading(event),
          ),
        );
      } else {
        return Scaffold(
          footers: [_buildBottom(context)],
          backgroundColor: Colors.black,
          child: PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            pageController: controller,
            builder: (BuildContext context, int index) {
              final url = widget.urls[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: PixivProvider.url(url),
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: url),
                filterQuality: FilterQuality.high,
              );
            },
            itemCount: widget.urls.length,
            onPageChanged: (index) async {
              nowUrl = widget.urls[index];
              setState(() {
                currentPage = index;
                shareShow = false;
              });
              var file = await imagesCacheManager.getFileFromCache(nowUrl);
              if (file != null) {
                setState(() {
                  shareShow = true;
                });
              }
            },
            loadingBuilder: (context, event) => _buildLoading(event),
          ),
        );
      }
    });
  }

  bool _fullScreen = false;

  Widget _buildBottom(BuildContext context) {
    if (_fullScreen) {
      return BottomAppBar(
        color: Colors.transparent,
        child: Row(
          children: [
            IconButton.ghost(
                onPressed: () {
                  setState(() {
                    _fullScreen = false;
                  });
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                      overlays: SystemUiOverlay.values);
                },
                icon: Icon(
                  Icons.fullscreen_exit,
                  color: Colors.white.withAlpha(50),
                ))
          ],
        ),
      );
    }
    return BottomAppBar(
      color: Colors.transparent,
      child: Visibility(
        visible: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton.ghost(
                  icon: Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                Text(
                  "${currentPage + 1}/${widget.urls.length}",
                  style: Theme.of(context)
                      .typography
                      .large
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton.ghost(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    }),
                IconButton.ghost(
                  icon: Icon(Icons.fullscreen, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _fullScreen = true;
                    });
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                        overlays: []);
                  },
                ),
                GestureDetector(
                    child: IconButton.ghost(
                        icon: Icon(
                          Icons.save_alt,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          File file = File(path.join(
                              BasePath.cachePath,
                              "share_cache",
                              path.basenameWithoutExtension(nowUrl) +
                                  (nowUrl.endsWith(".png") ? ".png" : ".jpg")));
                          if (!file.existsSync()) {
                            file.createSync(recursive: true);
                          }

                          saveUrl(widget.urls[currentPage]);
                        }),
                    onLongPress: () async {
                      saveUrl(widget.urls[currentPage]);
                    }),
                AnimatedOpacity(
                  opacity: shareShow ? 1 : 0.5,
                  duration: Duration(milliseconds: 500),
                  child: Builder(builder: (context) {
                    return IconButton.ghost(
                        icon: Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          var file =
                              await imagesCacheManager.getFileFromCache(nowUrl);
                          if (file != null) {
                            String targetPath = path.join(
                                BasePath.cachePath,
                                "share_cache",
                                path.basenameWithoutExtension(file.file.path) +
                                    (nowUrl.endsWith(".png")
                                        ? ".png"
                                        : ".jpg"));
                            File targetFile = File(targetPath);
                            if (!targetFile.existsSync()) {
                              targetFile.createSync(recursive: true);
                            }
                            file.file.copySync(targetPath);
                            final box =
                                context.findRenderObject() as RenderBox?;
                            Share.shareXFiles([XFile(targetPath)],
                                sharePositionOrigin:
                                    box!.localToGlobal(Offset.zero) & box.size);
                          } else {
                            Leader.showTextToast("can not find image cache");
                          }
                        });
                  }),
                ),
                // IconButton(
                //     icon: Icon(
                //       !_loadSource ? Icons.hd_outlined : Icons.hd,
                //       color: Colors.white,
                //     ),
                //     onPressed: () {
                //       setState(() {
                //         _loadSource = !_loadSource;
                //       });
                //     }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Center _buildLoading(ImageChunkEvent? event) {
    double value = event == null || event.expectedTotalBytes == null
        ? 0
        : event.cumulativeBytesLoaded / event.expectedTotalBytes!;
    if (value == 1.0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            shareShow = true;
          });
        }
      });
    }
    return Center(
      child: SizedBox(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(value: value),
      ),
    );
  }

  String getExtensionName() {
    var fileName = widget.urls[currentPage].split('/').last;
    if (fileName.contains('.')) {
      return '.${fileName.split('.').last}';
    }
    return '.jpg';
  }

  ImageProvider getImageProvider(String url) {
    if (url.startsWith("file://")) {
      return FileImage(File(url.replaceFirst("file://", "")));
    } else if (url.startsWith("novel:")) {
      // ignore: unused_local_variable
      var ids = url.split(':').last.split('/');
      throw UnimplementedError();
    }
    return PixivProvider.url(url);
  }
}
