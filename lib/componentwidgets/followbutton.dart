import 'package:moon_design/moon_design.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/like_controller.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

class UserFollowButton extends StatefulWidget {
  final bool liked;
  final String id;
  
  const UserFollowButton({super.key, required this.liked, required this.id});

  @override
  State<UserFollowButton> createState() => _UserFollowButtonState();
}

class _UserFollowButtonState extends State<UserFollowButton> {
  int get liked => widget.liked ? 2 : 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.transparent,
      child: Obx(() {
        switch (likeController.users[widget.id] ?? liked) {
          case 0:
            return filledButton(
                onPressed: () {
                  likeController.toggleUser(widget.id, liked);
                },
                label: "Follow".tr);
          case 1:
            return MoonButton.icon(
              buttonSize: MoonButtonSize.sm,
              showBorder: true,
              icon: Center(
                  child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                    width: 12,
                    height: 12,
                    child: MoonCircularLoader(
                      color: context.moonTheme?.tokens.colors.bulma,
                      circularLoaderSize: MoonCircularLoaderSize.sm,
                    )),
              )),
            );
          default:
            return filledButton(
              onPressed: () {
                likeController.toggleUser(widget.id, liked);
              },
              label: "Following".tr,
            );
        }
      }),
    );
  }
}
