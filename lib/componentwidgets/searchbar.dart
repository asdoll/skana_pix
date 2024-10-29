import 'package:flutter/material.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

import 'searchsuggestion.dart';

class SearchBar1 extends StatefulWidget {
  final ArtworkType type;
  const SearchBar1(this.type, {Key? key}) : super(key: key);

  @override
  State<SearchBar1> createState() => _SearchBar1State();
}

class _SearchBar1State extends State<SearchBar1> {
  late TextEditingController _textEditingController;
  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.grey.withOpacity(0.4)),
      child: Container(
        height: 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 8, right: 2),
              child: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            SearchSuggestionPage(widget.type)),
                  );
                },
                child: Container(
                  child: Text(
                    widget.type == ArtworkType.ILLUST
                        ? 'Search Illust or Manga'.i18n
                        : widget.type == ArtworkType.NOVEL
                            ? 'Search Novel'.i18n
                            : 'Search User'.i18n,
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.displaySmall!.color),
                  ),
                ),
              ),
            ),
            // Container(
            //   margin: const EdgeInsets.only(right: 8, left: 4),
            //   child: IconButton(
            //     icon: Icon(Icons.image_search),
            //     onPressed: () {
            //       if (widget.onSaucenao != null) widget.onSaucenao!();
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    ).paddingTop(10);
  }
}
