import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math';

class ShapeDisplayPage extends StatefulWidget {
  // final CameraDescription camera;
  final String shapename;

  const ShapeDisplayPage( {required this.shapename});

  @override
  _ShapeDisplayPageState createState() => _ShapeDisplayPageState();
}

class _ShapeDisplayPageState extends State<ShapeDisplayPage> {
  late String currentShapeName;

  @override
  void initState() {
    super.initState();
    currentShapeName = widget.shapename.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shapename),
      ),
      body: Stack(
        children: [
          const Center(child: CircularProgressIndicator()),
          CameraPreview( CameraController(const CameraDescription(name: "", lensDirection: CameraLensDirection.back, sensorOrientation: 0),ResolutionPreset.low),),
          Positioned.fill(
            child: Center(
              child: ShapeWidget(shapeName: currentShapeName),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        onPressed: () {
          
        },
      ),
    );
  }
}

class ShapeWidget extends StatelessWidget {
  final String shapeName;

  const ShapeWidget({super.key, required this.shapeName});

  @override
  Widget build(BuildContext context) {
    switch (shapeName) {
      case 'circle':
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(100),
          ),
        );
      case 'square':
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.red,
            border: Border.all(width: 2),
          ),
        );
      case 'triangle':
        return Container(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: TrianglePainter(),
          ),
        );
      case 'rectangle':
        return Container(
          width: 200,
          height: 200,
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          ),
        );
      case 'pentagon':
        return Container(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: PentagonPainter(),
          ),
        );
      default:
        return Container();
    }
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, Paint()..color = Colors.yellow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PentagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.orange;

    var path = Path();

    // Calculate pentagon vertices

    double angleStep = pi / 5;
    List<Offset> vertices = [
      Offset(size.width / 2, size.height / 2),
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width * 0.25, size.height * 0.75),
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.75, size.height * 0.75),
      Offset(size.width * 0.25, size.height * 0.5),
    ];

    // Draw pentagon
    for (int i = 0; i < vertices.length; i++) {
      int nextIndex = (i + 1) % vertices.length;
      path.moveTo(vertices[i].dx, vertices[i].dy);
      path.lineTo(vertices[nextIndex].dx, vertices[nextIndex].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
