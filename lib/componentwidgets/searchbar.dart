import 'package:flutter/material.dart';
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
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
                  style: TextStyle(fontSize: 16),
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
