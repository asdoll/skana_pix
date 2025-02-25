import 'package:moon_design/moon_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/selecthtml.dart';
import 'package:skana_pix/model/user.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
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
            child: 
            SizedBox(
              width: context.width,
              height: context.height,
          child: MoonTable(
            columnsCount: 2,
            rowSize: MoonTableRowSize.sm,
            width: context.width,
            tablePadding: const EdgeInsets.symmetric(horizontal: 16),
            rows: [
              MoonTableRow(
                  onTap: () {},
                  cells: [Text("Nickname".tr), Text(detail.name)]),
              MoonTableRow(
                  onTap: () {
                    try {
                      Clipboard.setData(
                          ClipboardData(text: detail.id.toString()));
                    } catch (e) {}
                  },
                  cells: [Text("Artist ID".tr), Text(detail.id.toString())]),
              MoonTableRow(
                onTap: () {
                  Get.to(() => FollowList(
                      isMyPixiv: false,
                      id: detail.id.toString(),
                      setAppBar: true));
                },
                cells: [
                  Text("Follows".tr),
                  Text(detail.totalFollowUsers.toString())
                ],
              ),
              MoonTableRow(
                  onTap: () {
                    Get.to(() => FollowList(
                        isMyPixiv: true,
                        id: detail.id.toString(),
                        setAppBar: true));
                  },
                  cells: [
                    Text("Total My Pixiv users".tr),
                    Text(detail.myPixivUsers.toString())
                  ]),
              MoonTableRow(
                  onTap: () async {
                    final url = detail.twitterUrl;
                    if (url != null && url.isNotEmpty) {
                      try {
                        await launchUrlString(url,
                            mode: LaunchMode.externalApplication);
                      } catch (e) {
                        Share.share(url);
                      }
                    }
                  },
                  cells: [Text("Twitter".tr), Text(detail.twitterUrl ?? "")]),
              MoonTableRow(
                onTap: () {},
                cells: [Text("Gender".tr), Text(detail.gender)],
              ),
              MoonTableRow(
                onTap: () {},
                cells: [Text("Job".tr), Text(detail.job)],
              ),
              MoonTableRow(
                onTap: () async {
                  if (detail.pawooUrl == null) return;
                  var url = detail.pawooUrl!;
                  try {
                    await launchUrlString(url,
                        mode: LaunchMode.externalApplication);
                  } catch (e) {
                    Share.share(url);
                  }
                },
                cells: [
                  Text("Pawoo".tr),
                  Text(detail.pawooUrl != null ? 'Link'.tr : "")
                ],
              )
            ],
          ),
        )).sliverPaddingHorizontal(8),
      ],
    );
  }
}
