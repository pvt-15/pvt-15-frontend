import 'package:flutter/material.dart';

class OverrideDialog extends StatefulWidget{
  const OverrideDialog({super.key});

  @override
  State<OverrideDialog> createState() => _OverrideDialog();

}

class _OverrideDialog extends State<OverrideDialog> {
  @override
  Widget build (BuildContext context) {
    return AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceBetween,
      title: Text(
        'Bilden kändes inte igen',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bilden kändes inte igen, vill du bekräfta bilden?',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ],
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Ta en ny bild'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text('Bekräfta'),
        )
      ],
    );
  }

  //TODO hur ska överskrivningen ske?
  //förslag:
  //Lägger till bilden i databasen utan ai analys

}