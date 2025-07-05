import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_ui_pack/widgets/signpad/signpad.dart';

class SignpadMain extends StatefulWidget {
  const SignpadMain({super.key});

  @override
  State<SignpadMain> createState() => _SignpadMainState();
}

class _SignpadMainState extends State<SignpadMain> {
  void _showImageModal(Uint8List pngBytes) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('저장된 이미지'),
          content: Image.memory(pngBytes, fit: BoxFit.contain),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignpadWidget(onSave: _showImageModal);
  }
}
