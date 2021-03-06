import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Algo Canvas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: CanvasPage(),
    );
  }
}

class CanvasPage extends StatefulWidget {
  @override
  _CanvasPageState createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  List<int> _tappedList = [];
  List<Offset> _pointList = [];
  List<String> _orientationList = ['S'];

  bool _isComplete = false;

  final double totalPadding = 16 * 2;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // Actual canvas area to be used for drawing
    double canvasWidth = MediaQuery.of(context).size.width - totalPadding;
    double canvasHeight =
        MediaQuery.of(context).size.height - totalPadding - statusBarHeight;

    // Taking each box side to be 30 pixels
    var eachBoxSize = 30.0;

    // Calculating the number of lines to be drawn
    var numberOfBoxesAlongWidth = canvasWidth ~/ eachBoxSize;
    var numberOfLinesAlongWidth = numberOfBoxesAlongWidth;

    var numberOfBoxesAlongHeight = canvasHeight ~/ eachBoxSize;
    var numberOfLinesAlongHeight = numberOfBoxesAlongHeight; // +1

    void _orientation(Offset p1, Offset p2, Offset p3) {
      var slope =
          (p2.dy - p1.dy) * (p3.dx - p2.dx) - (p2.dx - p1.dx) * (p3.dy - p2.dy);

      if (slope == 0) {
        print(''); // Linear
        _orientationList.add('');
      } else if (slope > 0) {
        print('R'); // Clockwise
        _orientationList.add('R');
      } else {
        print('L'); // Counter Clockwise
        _orientationList.add('L');
      }
    }

    print(_tappedList);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomPaint(
            painter: GridPainter(
              eachBoxSize: eachBoxSize,
              numberOfLinesAlongWidth: numberOfLinesAlongWidth,
              numberOfLinesAlongHeight: numberOfLinesAlongHeight,
            ),
            foregroundPainter: PolygonPainter(
              pointList: _pointList,
              orientationList: _orientationList,
              polygonColor: _isComplete ? Colors.green : Colors.red,
              eachBoxSize: eachBoxSize,
              numberOfLinesAlongWidth: numberOfLinesAlongWidth,
              numberOfLinesAlongHeight: numberOfLinesAlongHeight,
            ),
            child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: numberOfBoxesAlongWidth,
              children: List.generate(
                numberOfBoxesAlongWidth * numberOfBoxesAlongHeight,
                (index) {
                  bool islastTapped =
                      _tappedList.isEmpty ? true : _tappedList.last == index;
                  return InkWell(
                    onTapDown: (details) {
                      if (!_isComplete) {
                        Offset pointOffset = details.globalPosition -
                            details.localPosition +
                            Offset(eachBoxSize, eachBoxSize) -
                            Offset(
                                totalPadding, totalPadding + statusBarHeight);

                        if (_pointList.length > 1) {
                          _orientation(
                            pointOffset,
                            _pointList[_pointList.length - 1],
                            _pointList[_pointList.length - 2],
                          );
                        }

                        if (_pointList.length > 2) {
                          if (_pointList.contains(pointOffset)) {
                            setState(() {
                              _isComplete = true;
                            });
                          }
                          _pointList.add(pointOffset);
                        } else if (!_pointList.contains(pointOffset)) {
                          _pointList.add(pointOffset);
                        }
                      }
                    },
                    onTap: () {
                      if (!_isComplete) {
                        setState(() {
                          if (_tappedList.length > 2) {
                            _tappedList.add(index);
                            // if (_tappedList.contains(index)) {
                            //   setState(() {
                            //     _isComplete = true;
                            //   });
                            // }
                          } else if (!_tappedList.contains(index)) {
                            _tappedList.add(index);
                          }
                        });
                      }
                    },
                    child: Container(
                      height: eachBoxSize,
                      width: eachBoxSize,
                      child: _tappedList.contains(index)
                          ? Center(
                              child: Icon(
                                Icons.circle,
                                color: Colors.red.withOpacity(_isComplete
                                    ? 0.0
                                    : islastTapped
                                        ? 1.0
                                        : 0.3),
                                size: 10.0,
                              ),
                            )
                          : Container(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final double eachBoxSize;
  final int numberOfLinesAlongWidth;
  final int numberOfLinesAlongHeight;

  GridPainter({
    required this.eachBoxSize,
    required this.numberOfLinesAlongWidth,
    required this.numberOfLinesAlongHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Horizontal initial offsets
    var startPointHorizontal = Offset(0, 0);
    var endPointHorizontal = Offset(numberOfLinesAlongWidth * eachBoxSize, 0);

    // Vertical initial offsets
    var startPointVertical = Offset(0, 0);
    var endPointVertical = Offset(0, numberOfLinesAlongHeight * eachBoxSize);

    // Painter style
    var axisPaint = Paint()
      ..color = Colors.black12
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw axes
    for (int i = 0; i <= numberOfLinesAlongHeight; i++) {
      canvas.drawLine(startPointHorizontal, endPointHorizontal, axisPaint);
      canvas.drawLine(startPointVertical, endPointVertical, axisPaint);

      // horizontal increment
      var incrementHorizontal = Offset(0, eachBoxSize);
      startPointHorizontal += incrementHorizontal;
      endPointHorizontal += incrementHorizontal;

      // vertical increment
      var incrementVertical = Offset(eachBoxSize, 0);
      startPointVertical += incrementVertical;
      endPointVertical += incrementVertical;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Not repainting now
    return false;
  }
}

class PolygonPainter extends CustomPainter {
  final List<String> orientationList;
  final Color polygonColor;
  final List<Offset> pointList;
  final double eachBoxSize;
  final int numberOfLinesAlongWidth;
  final int numberOfLinesAlongHeight;

  PolygonPainter({
    required this.orientationList,
    required this.polygonColor,
    required this.pointList,
    required this.eachBoxSize,
    required this.numberOfLinesAlongWidth,
    required this.numberOfLinesAlongHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Painter style
    var linePaint = Paint()
      ..color = polygonColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    if (pointList.length > 1) {
      for (int i = 0; i < pointList.length - 1; i++) {
        var startPoint = pointList[i];
        var endPoint = pointList[i + 1];

        final textSpan = TextSpan(
          text: orientationList[i],
          style: TextStyle(color: Colors.black, fontSize: 14),
        );

        var textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout(minWidth: 0, maxWidth: 10);

        var textPosition;

        if (orientationList[i] == 'L') {
          textPosition = startPoint - Offset(0, 20);
        } else {
          textPosition = startPoint - Offset(0, 20);
        }

        canvas.drawLine(startPoint, endPoint, linePaint);
        textPainter.paint(canvas, textPosition);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repainting every time
    return false;
  }
}

class VisualizingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repainting every time
    return true;
  }
}
