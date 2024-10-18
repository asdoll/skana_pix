import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:skana_pix/controller/caches.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/view/defaults.dart';

import 'pixivimage.dart';

class ImageListPage extends StatefulWidget {
  final Illust illust;

  const ImageListPage(this.illust, {super.key});

  @override
  _ImageListPageState createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage> {
  @override
  Widget build(BuildContext context) {
    return ImagePage(widget.illust.images.map((e) => e.large).toList());
  }
}

class ImagePage extends StatefulWidget {
  const ImagePage(this.urls, {this.initialPage = 0, super.key});

  final List<String> urls;

  final int initialPage;

  // static show(List<String> urls, {int initialPage = 0}) {
  //   DynamicData.rootNavigatorKey.currentState?.push(AppPageRoute(
  //       builder: (context) => ImagePage(urls, initialPage: initialPage)));
  // }

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
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.black,
          bottomNavigationBar: _buildBottom(context),
          body: Container(
            child: PhotoView(
              filterQuality: FilterQuality.high,
              initialScale: PhotoViewComputedScale.contained,
              heroAttributes: PhotoViewHeroAttributes(tag: url),
              imageProvider: PixivProvider.url(url),
              loadingBuilder: (context, event) => _buildLoading(event),
            ),
          ),
        );
      } else {
        return Scaffold(
          extendBody: true,
          bottomNavigationBar: _buildBottom(context),
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.black,
          body: Container(
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
              if (file != null && mounted)
                setState(() {
                  shareShow = true;
                });
            },
            loadingBuilder: (context, event) => _buildLoading(event),
          )),
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
            IconButton(
                onPressed: () {
                  setState(() {
                    _fullScreen = false;
                  });
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                      overlays: SystemUiOverlay.values);
                },
                icon: Icon(
                  Icons.fullscreen_exit,
                  color: Colors.white.withOpacity(0.5),
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
                IconButton(
                  iconSize: 16,
                  icon: Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
                Text(
                  "${currentPage + 1}/${widget.urls.length}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.white),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    }),
                IconButton(
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
                    child: IconButton(
                        icon: Icon(
                          Icons.save_alt,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          //saveStore.saveImage(widget.urls[currentPage]);
                        }),
                    onLongPress: () async {
                      //saveStore.saveImage(widget.urls[currentPage]);
                    }),
                AnimatedOpacity(
                  opacity: shareShow ? 1 : 0.5,
                  duration: Duration(milliseconds: 500),
                  child: Builder(builder: (context) {
                    return IconButton(
                        icon: Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          var file =
                              await imagesCacheManager.getFileFromCache(nowUrl);
                          if (file != null) {
                            var fileName =
                                widget.urls[currentPage].split('/').last;
                            if (!fileName.contains('.')) {
                              fileName += getExtensionName();
                            }
                            saveFile(file.file, fileName);
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
      child: Container(
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
      var ids = url.split(':').last.split('/');
      throw UnimplementedError();
    }
    return PixivProvider.url(url);
  }
}
