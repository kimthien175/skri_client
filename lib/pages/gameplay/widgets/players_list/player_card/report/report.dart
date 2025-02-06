import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skribbl_client/models/models.dart';
import 'package:skribbl_client/pages/gameplay/widgets/players_list/player_card/report/content.dart';
import 'package:skribbl_client/utils/utils.dart';
import 'package:skribbl_client/widgets/widgets.dart';

class ReportFormDialog extends GameDialog {
  ReportFormDialog._internal({
    required this.info,
  }) : super(
            title: Builder(builder: (context) => Text(info.name)),
            content: const _ReportContent(),
            buttons: RowRenderObjectWidget(children: [
              GameDialogButton(
                  onTap: (onQuit) async {
                    var dialog =
                        Get.find<OverlayController>(tag: 'report ${info.id}') as ReportFormDialog;
                    // switch to loading icon
                    dialog.content.value = LoadingIndicator();
                    dialog.buttons.value = null;
                    // submit report
                    var res = await API.inst.post('report_player', {
                      'player': info.toJSON(),
                      'room': Game.inst.roomCode,
                      'reasons': [dialog.reason1, dialog.reason2, dialog.reason3]
                    });
                    if (res.statusCode == 200) {
                      dialog.content.value = Text('Your report has been received, thank you');
                      dialog.buttons.value = null;
                      await Future.delayed(const Duration(seconds: 2));
                      await onQuit();
                      return true;
                    } else {
                      await dialog.hideInstantly();
                      GameDialog.error(content: Center(child: Text(res.body.toString())))
                          .showInstantly();
                      return false;
                    }
                  },
                  child: const _DialogReportButton())
            ]));
  factory ReportFormDialog.factory(Player info) {
    return OverlayController.cache(
        tag: 'report ${info.id}', builder: () => ReportFormDialog._internal(info: info));
  }
  bool reason1 = false;
  bool reason2 = false;
  bool reason3 = false;
  final Player info;
  @override
  String get tag => 'report ${info.id}';
}

class _ReportContent extends StatelessWidget {
  const _ReportContent();
  @override
  Widget build(BuildContext context) {
    var controller = OverlayWidget.of<ReportFormDialog>(context);
    return ReportContentObjectWidget(children: [
      Text('report_form_title'.tr),
      Text('report_form_reason_inappropriate'.tr),
      GameCheckbox(onChanged: (value) => controller.reason1 = value),
      Text('report_form_reason_spam'.tr),
      GameCheckbox(onChanged: (value) => controller.reason2 = value),
      Text('report_form_reason_cheating'.tr),
      GameCheckbox(onChanged: (value) => controller.reason3 = value)
    ]);
  }
}

class _DialogReportButton extends OKayDialogButtonChild {
  const _DialogReportButton();
  @override
  String get content => 'Report'.tr;
}
