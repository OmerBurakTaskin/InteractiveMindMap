import 'package:flutter/material.dart';

void normalDialogBuilder(
    BuildContext context,
    String? title,
    String content,
    String choice1Text,
    String choice2Text,
    Function onPressed1,
    Function onPressed2) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: title != null ? Text(title) : null,
        content: Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: Text(choice1Text),
            onPressed: () => onPressed1(),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: Text(choice2Text),
            onPressed: () => onPressed2(),
          ),
        ],
      );
    },
  );
}
