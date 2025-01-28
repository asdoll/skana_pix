import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' show SelectionArea;
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/selecthtml.dart';
import 'package:skana_pix/model/user.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../view/userview/followlist.dart';

class UserDetailPage extends StatefulWidget {
  final UserDetails userDetail;
  const UserDetailPage(this.userDetail, {super.key});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  UserDetails get userDetail => widget.userDetail;

  @override
  Widget build(BuildContext context) {
    UserDetails detail = widget.userDetail;
    return _buildScrollView(context, detail);
  }

  CustomScrollView _buildScrollView(BuildContext context, UserDetails detail) {
    return CustomScrollView(
      key: PageStorageKey<String>("user_detail${userDetail.id}"),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: SelectionArea(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: detail.comment.isNotEmpty
                        ? SelectableHtml(data: detail.comment)
                        : const SelectableHtml(
                            data: '~',
                          )),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              rows: [
                TableRow(cells: [
                  TableCell(child: Text("Nickname".tr)),
                  TableCell(child: Expanded(child: Text(detail.name))),
                ]),
                TableRow(cells: [
                  TableCell(child: Text("Artist ID".tr)),
                  TableCell(
                      child: TextButton(
                          child: Text(detail.id.toString()),
                          onPressed: () {
                            try {
                              Clipboard.setData(
                                  ClipboardData(text: detail.id.toString()));
                            } catch (e) {}
                          })),
                ]),
                TableRow(cells: [
                  TableCell(child: Text("Follows".tr)),
                  TableCell(
                      child: TextButton(
                          child: Text(detail.totalFollowUsers.toString()),
                          onPressed: () {
                            Get.to(() => Scaffold(
                                  headers: [
                                    AppBar(
                                      title: Text("Followed".tr),
                                    )
                                  ],
                                  child:
                                      FollowList(id: detail.id.toString(), isNovel: false),
                                ));
                          }))
                ]),
                TableRow(cells: [
                  TableCell(child: Text("Total My Pixiv users".tr)),
                  TableCell(
                      child: TextButton(
                          child: Text(detail.myPixivUsers.toString()),
                          onPressed: () {
                            Get.to(() => Scaffold(
                                  headers: [
                                    AppBar(
                                      title: Text("Followed".tr),
                                    )
                                  ],
                                  child: FollowList(
                                    id: detail.id.toString(),
                                    isMyPixiv: true,
                                  ),
                                ));
                          })),
                ]),
                TableRow(cells: [
                  TableCell(child: Text("Twitter")),
                  TableCell(
                      child: TextButton(
                          child: Text(detail.twitterUrl ?? ""),
                          onPressed: () async {
                            final url = detail.twitterUrl;
                            if (url != null) {
                              try {
                                await launchUrlString(url,
                                    mode: LaunchMode.externalApplication);
                              } catch (e) {
                                Share.share(url);
                              }
                            }
                          }))
                ]),
                TableRow(cells: [
                  TableCell(child: Text("Gender".tr)),
                  TableCell(child: Text(detail.gender)),
                ]),
                TableRow(cells: [
                  TableCell(child: Text("Job".tr)),
                  TableCell(child: Text(detail.job)),
                ]),
                TableRow(cells: [
                  TableCell(child: Text('Pawoo')),
                  TableCell(
                      child: TextButton(
                          child:
                              Text(detail.pawooUrl != null ? 'Link' : 'none'),
                          onPressed: () async {
                            if (detail.pawooUrl == null) return;
                            var url = detail.pawooUrl!;
                            try {
                              await launchUrlString(url,
                                  mode: LaunchMode.externalApplication);
                            } catch (e) {
                              Share.share(url);
                            }
                          })),
                ]),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 200,
          ),
        )
      ],
    );
  }
}
