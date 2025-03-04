import 'package:flutter/material.dart';

Widget buildCodeBlock(String command) {
  return Container(
    padding: const EdgeInsets.all(10),
    margin: const EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(8),
    ),
    child: SelectableText(
      command,
      style: const TextStyle(
        fontSize: 14,
        fontFamily: 'monospace',
        color: Colors.greenAccent,
      ),
    ),
  );
}
