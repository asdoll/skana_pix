import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/model/spotlight.dart';
import 'package:skana_pix/utils/io_extension.dart';
import 'package:skana_pix/view/imageview/imagelistview.dart';
import 'package:skana_pix/componentwidgets/nullhero.dart';
import 'package:skana_pix/controller/soup_controller.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../componentwidgets/avatar.dart';
import '../componentwidgets/pixivimage.dart';

class SoupPage extends StatefulWidget {
  final String url;
  final SpotlightArticle? spotlight;
  final String? heroTag;

  const SoupPage(
      {super.key, required this.url, required this.spotlight, this.heroTag});

  @override
  State<SoupPage> createState() => _SoupPageState();
}

class _SoupPageState extends State<SoupPage> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<SoupFetcher>(tag: "soupFetcher_${widget.heroTag}");
  }

  @override
  Widget build(BuildContext context) {
    SoupFetcher soupFetcher =
        Get.put(SoupFetcher(), tag: "soupFetcher_${widget.heroTag}");
    soupFetcher.fetch(widget.url);
    return Obx(() {
      return Scaffold(
        body: NestedScrollView(
          body: soupFetcher.amWorks.isEmpty
              ? Center(
                  child: DefaultHeaderFooter.progressIndicator(context),
                )
              : ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return Builder(builder: (context) {
                      if (index == 0) {
                        if (soupFetcher.description.isEmpty) {
                          return Container(height: 1);
                        }
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(soupFetcher.description).appHeader(),
                          ),
                        );
                      }
                      AmWork amWork = soupFetcher.amWorks[index - 1];
                      return InkWell(
                        onTap: () {
                          int id = int.parse(Uri.parse(amWork.arworkLink!)
                              .pathSegments[Uri.parse(amWork.arworkLink!)
                                  .pathSegments
                                  .length -
                              1]);
                          Get.to(() => IllustPageLite(id.toString()),
                              preventDuplicates: false);
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  PainterAvatar(
                                    url: amWork.userImage!,
                                    id: int.parse(Uri.parse(amWork.userLink!)
                                            .pathSegments[
                                        Uri.parse(amWork.userLink!)
                                                .pathSegments
                                                .length -
                                            1]),
                                    size: 50,
                                  ),
                                  SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(trimSize(amWork.title!))
                                          .appSubHeader(),
                                      SizedBox(height: 4),
                                      Text(amWork.user!).subHeader(),
                                    ],
                                  ),
                                ],
                              ).paddingVertical(8),
                              PixivImage(amWork.showImage!).rounded(8),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                  itemCount: soupFetcher.amWorks.length + 1,
                ),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              if (widget.spotlight != null)
                SliverAppBar(
                  leading: IconButton(
                    icon: DecoratedIcon(
                      icon: Icon(Icons.arrow_back),
                      decoration:
                          IconDecoration(border: IconBorder(width: 1.5)),
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  pinned: true,
                  expandedHeight: 200.0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.symmetric(horizontal: 40),
                    centerTitle: true,
                    title: Stack(
                      children: <Widget>[
                        // Stroked text as border.
                        Text(
                          widget.spotlight!.pureTitle,
                          style: TextStyle(
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 0.5
                              ..color = Colors.black,
                          ),
                        ).subHeaderForgound(),
                        // Solid text as fill.
                        Text(
                          widget.spotlight!.pureTitle,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ).subHeader(),
                      ],
                    ),
                    background: NullHero(
                      tag: widget.heroTag,
                      child: PixivImage(
                        widget.spotlight!.thumbnail,
                        fit: BoxFit.cover,
                        height: 200,
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: const DecoratedIcon(
                        icon: Icon(Icons.share, color: Colors.white),
                        decoration:
                            IconDecoration(border: IconBorder(width: 1.5)),
                      ),
                      onPressed: () async {
                        var url = widget.spotlight!.articleUrl;
                        await launchUrlString(url);
                      },
                    )
                  ],
                )
              else
                SliverAppBar()
            ];
          }),
      );
    });
  }
}
