import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/like_controller.dart';

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
      height: 32,
      color: Colors.transparent,
      child: Obx(() {
        switch (likeController.users[widget.id] ?? liked) {
          case 0:
            return IconButton.outline(
                onPressed: () {
                  likeController.toggleUser(widget.id, liked);
                },
                icon: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      "Follow".tr,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ));
          case 1:
            return IconButton.primary(
                icon: const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                    width: 12, height: 12, child: CircularProgressIndicator()),
              ),
            ));
          default:
            return IconButton.outline(
                onPressed: () {
                  likeController.toggleUser(widget.id, liked);
                },
                icon: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      "Following".tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ));
        }
      }),
    );
  }
}
