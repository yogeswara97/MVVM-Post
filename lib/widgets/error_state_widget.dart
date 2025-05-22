import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onPressed;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(message),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: onPressed,
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
