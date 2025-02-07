import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' show SelectionArea;
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
        SliverList(
          delegate: SliverChildListDelegate([
            Button.card(
              onPressed: () {},
              trailing: Text(detail.name),
              child: Text("Nickname".tr),
            ),
            Button.card(
              onPressed: () {
                try {
                  Clipboard.setData(ClipboardData(text: detail.id.toString()));
                } catch (e) {}
              },
              trailing: Text(detail.id.toString()),
              child: Text("Artist ID".tr),
            ),
            Button.card(
              onPressed: () {
                Get.to(() => FollowList(
                    isMyPixiv: false,
                    id: detail.id.toString(),
                    setAppBar: true));
              },
              trailing: Text(detail.totalFollowUsers.toString()),
              child: Text("Follows".tr),
            ),
            Button.card(
              onPressed: () {
                Get.to(() => FollowList(
                    isMyPixiv: true,
                    id: detail.id.toString(),
                    setAppBar: true));
              },
              trailing: Text(detail.myPixivUsers.toString()),
              child: Text("Total My Pixiv users".tr),
            ),
            Button.card(
              onPressed: () async {
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
              trailing: Text(detail.twitterUrl ?? ""),
              child: Text("Twitter".tr),
            ),
            Button.card(
              onPressed: () {},
              trailing: Text(detail.gender),
              child: Text("Gender".tr),
            ),
            Button.card(
              onPressed: () {},
              trailing: Text(detail.job),
              child: Text("Job".tr),
            ),
            Button.card(
              onPressed: () async {
                if (detail.pawooUrl == null) return;
                var url = detail.pawooUrl!;
                try {
                  await launchUrlString(url,
                      mode: LaunchMode.externalApplication);
                } catch (e) {
                  Share.share(url);
                }
              },
              trailing: Text(detail.pawooUrl != null ? 'Link' : 'none'),
              child: Text("Pawoo".tr),
            )
          ]),
        ).sliverPaddingHorizontal(8),
      ],
    );
  }
}
