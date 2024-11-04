import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

import 'novelbookmark.dart';
import 'novelpage.dart';
import 'pixivimage.dart';

class NovelCard extends StatefulWidget {
  final Novel novel;
  const NovelCard(this.novel, {super.key});

  @override
  State<NovelCard> createState() => _NovelCardState();
}

class _NovelCardState extends State<NovelCard> {
  Novel get novel => widget.novel;
  @override
  Widget build(BuildContext context) {
    {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: InkWell(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                builder: (BuildContext context) => NovelViewerPage(novel)));
          },
          child: Card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: PixivImage(
                          novel.coverImageUrl,
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                        ).rounded(8.0),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, left: 8.0),
                              child: Text(
                                novel.title,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyLarge,
                                maxLines: 3,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    novel.author.name.atMost8,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.sticky_note_2_outlined,
                                          size: 12,
                                          color: Theme.of(context)
                                              .textTheme
                                              .labelSmall!
                                              .color,
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Text(
                                          '${novel.length}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 2, // gap between adjacent chips
                                runSpacing: 0,
                                children: [
                                  if(novel.tags.isEmpty)
                                    Container(),
                                  for (var f in novel.tags)
                                    Text(
                                      f.name,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    )
                                ],
                              ),
                            ),
                            Container(
                              height: 8.0,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      NovelBookmarkButton(novel: novel, colorMode: ""),
                      Text('${novel.totalBookmarks}',
                          style: Theme.of(context).textTheme.bodySmall)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}
