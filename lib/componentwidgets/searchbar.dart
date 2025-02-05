import 'package:flutter/material.dart' show InkWell;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/model/worktypes.dart';
import 'package:get/get.dart';

import '../view/search/searchsuggestion.dart';

class SearchBar1 extends StatefulWidget {
  final ArtworkType type;
  const SearchBar1(this.type, {super.key});

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
    return SizedBox(
      height: 48,
      child: Card(
        padding: EdgeInsets.symmetric(horizontal: 16),
        fillColor: Colors.gray.shade400,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton.ghost(
              icon: Icon(Icons.search),
              onPressed: () {},
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.to(() => SearchSuggestionPage(widget.type),
                      preventDuplicates: false);
                },
                child: Text(
                  widget.type == ArtworkType.ILLUST
                      ? 'Search Illust or Manga'.tr
                      : widget.type == ArtworkType.NOVEL
                          ? 'Search Novel'.tr
                          : 'Search User'.tr,
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).typography.xSmall.color),
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
    );
  }
}
