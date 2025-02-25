import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/controller/page_index_controller.dart';

class GoTop extends StatelessWidget {
  const GoTop({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: (homeController.showBackArea.value)
              ? MoonButton.icon(
                  buttonSize: MoonButtonSize.lg,
                  showBorder: true,
                  borderColor: Get
                      .context?.moonTheme?.buttonTheme.colors.borderColor
                      .withValues(alpha: 0.5),
                  backgroundColor: Get.context?.moonTheme?.tokens.colors.zeno,
                  onTap: () {
                    globalScrollController.animateTo(0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                  icon: Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                  ),
                )
              : Container(),
        ));
  }
}
