import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/controller/mini_controllers.dart';
import 'package:skana_pix/controller/page_index_controller.dart';

class GoTop extends StatelessWidget {
  const GoTop({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: (homeController.showBackArea.value)
              ? Button(
                  style: ButtonStyle.card(
                      size: ButtonSize.small, density: ButtonDensity.dense),
                  onPressed: () {
                    globalScrollController.animateTo(0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                  child: Icon(
                    Icons.arrow_upward,
                    size: 30,
                  ).paddingOnly(right: 6, top: 1, bottom: 1),
                )
                  .withAlign(Alignment(1.05, 0.9))
                  .paddingOnly(bottom: Get.mediaQuery.size.height * 0.05)
              : Container(),
        ));
  }
}
