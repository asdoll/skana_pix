import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/navigation.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/defaults.dart';

import 'routes.dart';

class ImageListPage extends StatefulWidget {
  
  final Illust illust;

  const ImageListPage(this.illust,{super.key});

  @override
  _ImageListPageState createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ImagePage extends StatefulWidget {
  const ImagePage(this.urls, {this.initialPage = 0, super.key});

  final List<String> urls;

  final int initialPage;

  static show(List<String> urls, {int initialPage = 0}) {
    DynamicData.rootNavigatorKey.currentState?.push(AppPageRoute(
        builder: (context) => ImagePage(urls, initialPage: initialPage)));
  }

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  late var controller = PageController(initialPage: widget.initialPage);

  late int currentPage = widget.initialPage;

  // Future<File?> getFile() async {
  //   var image = widget.urls[currentPage];
  //   if (image.startsWith("file://")) {
  //     return File(image.replaceFirst("file://", ""));
  //   }
  //   var key = image;
  //   if (key.startsWith("novel:")) {
  //     key = key.split(':').last;
  //   }
  //   var file = await CacheManager().findCache(key);
  //   return file == null ? null : File(file);
  // }

  String getExtensionName() {
    var fileName = widget.urls[currentPage].split('/').last;
    if (fileName.contains('.')) {
      return '.${fileName.split('.').last}';
    }
    return '.jpg';
  }

  // void showMenu() {
  //   menuController.showFlyout(
  //       barrierColor: Colors.transparent,
  //       position: App.isMobile ? Offset(context.size!.width, 0) : null,
  //       builder: (context) => MenuFlyout(
  //             items: [
  //               MenuFlyoutItem(
  //                   text: Text("Save to".tl),
  //                   onPressed: () async {
  //                     var file = await getFile();
  //                     if (file != null) {
  //                       var fileName = widget.urls[currentPage].split('/').last;
  //                       if (!fileName.contains('.')) {
  //                         fileName += getExtensionName();
  //                       }
  //                       saveFile(file, fileName);
  //                     }
  //                   }),
  //               if (App.isMobile)
  //                 MenuFlyoutItem(
  //                     text: Text("Save to gallery".tl),
  //                     onPressed: () async {
  //                       var file = await getFile();
  //                       if (file != null) {
  //                         var fileName =
  //                             widget.urls[currentPage].split('/').last;
  //                         if (!fileName.contains('.')) {
  //                           fileName += getExtensionName();
  //                         }
  //                         await ImageGallerySaver.saveImage(
  //                             await file.readAsBytes(),
  //                             quality: 100,
  //                             name: fileName);
  //                         if (mounted) {
  //                           showToast(context, message: "Saved".tl);
  //                         }
  //                       }
  //                     }),
  //               MenuFlyoutItem(
  //                   text: Text("Share".tl),
  //                   onPressed: () async {
  //                     var file = await getFile();
  //                     if (file != null) {
  //                       var ext = getExtensionName();
  //                       var fileName = widget.urls[currentPage].split('/').last;
  //                       if (!fileName.contains('.')) {
  //                         fileName += ext;
  //                       }
  //                       var mediaType = switch (ext) {
  //                         '.jpg' => 'image/jpeg',
  //                         '.jpeg' => 'image/jpeg',
  //                         '.png' => 'image/png',
  //                         '.gif' => 'image/gif',
  //                         '.webp' => 'image/webp',
  //                         _ => 'application/octet-stream'
  //                       };
  //                       Share.shareXFiles([
  //                         XFile.fromData(await file.readAsBytes(),
  //                             mimeType: mediaType, name: fileName)
  //                       ]);
  //                     }
  //                   }),
  //             ],
  //           ));
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: Theme.of(context).scaffoldBackgroundColor,
      child:LayoutBuilder(
          builder: (context, constrains) {
            var height = constrains.maxHeight;
            return Stack(
              children: [
                // Positioned.fill(
                //     child: PhotoViewGallery.builder(
                //   pageController: controller,
                //   backgroundDecoration:
                //       const BoxDecoration(color: Colors.transparent),
                //   itemCount: widget.urls.length,
                //   builder: (context, index) {
                //     var image = widget.urls[index];

                //     return PhotoViewGalleryPageOptions(
                //       filterQuality: FilterQuality.medium,
                //       imageProvider: getImageProvider(image),
                //     );
                //   },
                //   onPageChanged: (index) {
                //     setState(() {
                //       currentPage = index;
                //     });
                //   },
                // )),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: 36,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 6,
                        ),
                        IconButton(
                            icon: const Icon(Icons.keyboard_backspace).paddingAll(2),
                            onPressed: () => context.pop()),
                        // const Expanded(
                        //   child: DragToMoveArea(
                        //     child: SizedBox.expand(),
                        //   ),
                        // ),
                        buildActions(),
                      ],
                    ),
                  ),
                ),
                if (currentPage != 0)
                  Positioned(
                    left: 0,
                    top: height / 2 - 9,
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_left,
                        size: 18,
                      ),
                      onPressed: () {
                        controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ).paddingAll(8),
                  ),
                if (currentPage != widget.urls.length - 1)
                  Positioned(
                    right: 0,
                    top: height / 2 - 9,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right, size: 18),
                      onPressed: () {
                        controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ).paddingAll(8),
                  ),
                Positioned(
                  left: 12,
                  bottom: 8,
                  child: Text(
                    "${currentPage + 1}/${widget.urls.length}",
                  ),
                )
              ],
            );
          },
        ),
    );
  }

  Widget buildActions() {
    // return FlyoutTarget(
    //   controller: menuController,
    //   child: 
    //          IconButton(
    //         icon: const Icon(
    //             Icons.more_horiz,
    //             size: 20,
    //           ),
    //           onPressed: showMenu),
    // );
    throw UnimplementedError();
  }

  ImageProvider getImageProvider(String url) {
    if (url.startsWith("file://")) {
      return FileImage(File(url.replaceFirst("file://", "")));
    } else if (url.startsWith("novel:")) {
      var ids = url.split(':').last.split('/');
      throw UnimplementedError();
    }
    return CachedNetworkImageProvider(url);
  }
}