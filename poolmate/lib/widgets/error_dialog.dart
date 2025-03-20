import 'package:flutter/material.dart';
import 'custom_button.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;

  const ErrorDialog({
    Key? key,
    this.title = 'Error',
    required this.message,
    this.buttonText,
    this.onRetry,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    String title = 'Error',
    required String message,
    String? buttonText,
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        buttonText: buttonText,
        onRetry: onRetry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
      actions: [
        if (onRetry != null)
          CustomButton(
            text: buttonText ?? 'Retry',
            onPressed: () {
              Navigator.of(context).pop();
              onRetry?.call();
            },
            backgroundColor: theme.colorScheme.error,
          )
        else
          CustomButton(
            text: buttonText ?? 'OK',
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: theme.colorScheme.error,
          ),
      ],
      actionsPadding: const EdgeInsets.all(16),
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    String? title,
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }
}