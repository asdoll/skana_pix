import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skana_pix/componentwidgets/selecthtml.dart';
import 'package:skana_pix/model/user.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'followlist.dart';

class UserDetailPage extends StatefulWidget {
  final UserDetails userDetail;
  const UserDetailPage(this.userDetail, {Key? key}) : super(key: key);

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
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
            child: DataTable(
              columns: <DataColumn>[
                DataColumn(label: Text("Nickname".i18n)),
                DataColumn(label: Expanded(child: Text(detail.name))),
              ],
              rows: <DataRow>[
                DataRow(cells: [
                  DataCell(Text("Artist ID".i18n)),
                  DataCell(Text(detail.id.toString()), onTap: () {
                    try {
                      Clipboard.setData(
                          ClipboardData(text: detail.id.toString()));
                    } catch (e) {}
                  }),
                ]),
                DataRow(cells: [
                  DataCell(Text("Follows".i18n)),
                  DataCell(Text(detail.totalFollowUsers.toString()), onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(
                          title: Text("Followed".i18n),
                        ),
                        body: FollowList(id: detail.id, isNovel: false),
                      );
                    }));
                  }),
                ]),
                DataRow(cells: [
                  DataCell(Text("Total My Pixiv users".i18n)),
                  DataCell(Text(detail.myPixivUsers.toString()), onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(),
                        body: FollowList(
                          id: detail.id,
                          isMyPixiv: true,
                        ),
                      );
                    }));
                  }),
                ]),
                DataRow(cells: [
                  DataCell(Text("Twitter")),
                  DataCell(Text(detail.twitterUrl ?? ""), onTap: () async {
                    final url = detail.twitterUrl;
                    if (url != null) {
                      try {
                        await launchUrlString(url,
                            mode: LaunchMode.externalApplication);
                      } catch (e) {
                        Share.share(url);
                      }
                    }
                  }),
                ]),
                DataRow(cells: [
                  DataCell(Text("Gender".i18n)),
                  DataCell(Text(detail.gender)),
                ]),
                DataRow(cells: [
                  DataCell(Text("Job".i18n)),
                  DataCell(Text(detail.job)),
                ]),
                DataRow(cells: [
                  DataCell(Text('Pawoo')),
                  DataCell(Text(detail.pawooUrl != null ? 'Link' : 'none'),
                      onTap: () async {
                    if (detail.pawooUrl == null) return;
                    var url = detail.pawooUrl!;
                    try {
                      await launchUrlString(url,
                          mode: LaunchMode.externalApplication);
                    } catch (e) {
                      Share.share(url);
                    }
                  }),
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