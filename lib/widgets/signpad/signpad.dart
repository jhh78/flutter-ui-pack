import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SignpadWidget extends StatefulWidget {
  const SignpadWidget({
    super.key,
    required this.onSave,
    this.helperText = '아래 영역에 서명해주세요',
    this.saveButtonText = '이미지 저장',
    this.clearButtonText = '지우기',
  });

  final Function(Uint8List) onSave; // 이미지 저장 콜백
  final String helperText;
  final String saveButtonText;
  final String clearButtonText;

  @override
  SignpadWidgetState createState() => SignpadWidgetState();
}

class SignpadWidgetState extends State<SignpadWidget> {
  final List<Offset?> _points = <Offset?>[];
  final GlobalKey _signatureKey = GlobalKey(); // 서명 영역의 GlobalKey
  final GlobalKey _repaintBoundaryKey = GlobalKey(); // RepaintBoundary의 GlobalKey

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      RenderBox? renderBox = _signatureKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        Offset localPosition = renderBox.globalToLocal(details.globalPosition);
        _points.add(localPosition);
      }
    });
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      RenderBox? renderBox = _signatureKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        Offset localPosition = renderBox.globalToLocal(details.globalPosition);
        _points.add(localPosition);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _points.add(null);
    });
  }

  void _clearSignature() {
    setState(() {
      _points.clear();
    });
  }

  Future<void> _saveSignature() async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        widget.onSave(pngBytes); // 콜백으로 이미지 전달
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사인패드'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(widget.helperText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // 서명 입력 영역
            Expanded(
              child: RepaintBoundary(
                key: _repaintBoundaryKey, // RepaintBoundary의 GlobalKey
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: GestureDetector(
                      key: _signatureKey,
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: CustomPaint(painter: SignaturePainter(_points), child: Container()),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 버튼 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _clearSignature,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: Text(widget.clearButtonText),
                ),
                ElevatedButton(
                  onPressed: _saveSignature,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: Text(widget.saveButtonText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..color = Colors.black
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return true;
  }
}
