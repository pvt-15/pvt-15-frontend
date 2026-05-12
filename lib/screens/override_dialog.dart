import 'package:flutter/material.dart';

import '../widgets/custom_alert_dialog.dart';

class OverrideDialog extends StatelessWidget {
  const OverrideDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      title: 'Bilden kändes inte igen',
      content: 'Bilden kändes inte igen, vill du bekräfta bilden?',
      cancelText: 'Ta en ny bild',
      confirmText: 'Bekräfta',
      onCancel: () => Navigator.pop(context),
      onConfirm: () => Navigator.pop(context, true),
    );
  }

  //TODO hur är det tänkt att den ska fungera?
}
