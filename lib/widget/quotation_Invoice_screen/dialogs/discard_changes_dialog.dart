import 'package:flutter/material.dart';

class DiscardChangesDialog extends StatelessWidget {
  final String title;
  final String message;

  const DiscardChangesDialog({
    Key? key,
    this.title = 'Unsaved Changes',
    this.message =
        'You have unsaved changes. Are you sure you want to go back without saving?',
  }) : super(key: key);

  static Future<bool> show(
    BuildContext context, {
    String? title,
    String? message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DiscardChangesDialog(
        title: title ?? 'Unsaved Changes',
        message: message ??
            'You have unsaved changes. Are you sure you want to go back without saving?',
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
        ],
      ),
      content: Text(message, style: TextStyle(color: Colors.grey.shade700, height: 1.5)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text('Discard'),
        ),
      ],
    );
  }
}