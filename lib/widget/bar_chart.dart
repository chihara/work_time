
import 'package:flutter/material.dart';

/// 棒グラフを表示するカスタムwidget
class BarChart extends StatefulWidget {
  final double value;
  final double border;
  final double max;
  final Color baseColor;
  final Color mainColor;
  final Color overColor;
  final Color shortColor;
  final Color inactiveColor;
  final double lineWidth;
  final bool inactivated;

  BarChart(
      this.value,
      this.border,
      this.max,
      {
        this.baseColor = Colors.black12,
        this.mainColor = Colors.indigo,
        this.overColor = Colors.cyan,
        this.shortColor = Colors.orange,
        this.inactiveColor = Colors.black38,
        this.lineWidth = 6.0,
        this.inactivated = false,
        Key key,
      }
      ): super(key: key);

  @override
  State<StatefulWidget> createState() => _BarChart();
}

class _BarChart extends State<BarChart> {
  _ColorSet colorSet;

  @override
  void initState() {
    super.initState();
    colorSet = _ColorSet(
        widget.baseColor,
        widget.mainColor,
        widget.overColor,
        widget.shortColor,
        widget.inactiveColor
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.0,
      height: 6.0,
      child: CustomPaint(
        foregroundPainter: _Painter(
            widget.value,
            widget.border,
            widget.max,
            colorSet,
            widget.lineWidth,
            widget.inactivated),
      )
    );
  }
}

class _Painter extends CustomPainter {
  final double actual;
  final double fixed;
  double percentageActual;
  double percentageFixed;
  final double lineWidth;
  final _ColorSet colorSet;
  final bool inactivated;

  _Painter(
      this.actual,
      this.fixed,
      double max,
      this.colorSet,
      this.lineWidth,
      this.inactivated
  ) {
    percentageActual = actual / max;
    if (1.0 < percentageActual)
      percentageActual = 1.0;
    percentageFixed = fixed / max;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double y = (size.height - lineWidth) / 2 + (lineWidth / 2);
    Offset p1 = Offset(0.0, y);
    Offset p2 = Offset((size.width * percentageActual), y);
    Offset p3 = Offset((size.width * percentageFixed), y);
    Offset p4 = Offset(size.width, y);

    var gradientMain = LinearGradient(
      colors: [Color.lerp(colorSet.mainColor, Colors.white, 0.5), colorSet.mainColor,],
      stops: [0.0, 1.0],
    );
    var gradientOver = LinearGradient(
      colors: [Color.lerp(colorSet.overColor, Colors.white, 0.5), colorSet.overColor,],
      stops: [0.0, 1.0],
    );
    var gradientShort = LinearGradient(
      colors: [Color.lerp(colorSet.shortColor, Colors.white, 0.5), colorSet.shortColor,],
      stops: [0.0, 1.0],
    );
    var gradientInactive = LinearGradient(
      colors: [Color.lerp(colorSet.inactiveColor, Colors.white, 0.7), colorSet.inactiveColor,],
      stops: [0.0, 1.0],
    );

    Paint paintBase = Paint()
        ..color = colorSet.baseColor
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth;
    canvas.drawLine(p1, p4, paintBase);

    Paint paintBar = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;
    if (inactivated) {
      paintBar = paintBar..shader = gradientInactive.createShader(Rect.fromPoints(Offset(0.0, 0.0), Offset(p2.dx, size.height)));
      canvas.drawLine(p1, p2, paintBar);
    } else if (fixed < actual) {
      paintBar = paintBar..shader = gradientOver.createShader(Rect.fromPoints(Offset(0.0, 0.0), Offset(p2.dx, size.height)));
      canvas.drawLine(p1, p2, paintBar);
      paintBar = paintBar..shader = gradientMain.createShader(Rect.fromPoints(Offset(0.0, 0.0), Offset(p3.dx, size.height)));
      canvas.drawLine(p1, p3, paintBar);
    } else if (fixed > actual) {
      paintBar = paintBar..shader = gradientShort.createShader(Rect.fromPoints(Offset(0.0, 0.0), Offset(p3.dx, size.height)));
      canvas.drawLine(p1, p3, paintBar);
      if (p1 != p2) {
        paintBar = paintBar..shader = gradientMain.createShader(Rect.fromPoints(Offset(0.0, 0.0), Offset(p2.dx, size.height)));
        canvas.drawLine(p1, p2, paintBar);
      }
    } else {
      paintBar = paintBar..shader = gradientMain.createShader(Rect.fromPoints(Offset(0.0, 0.0), Offset(p2.dx, size.height)));
      canvas.drawLine(p1, p2, paintBar);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _ColorSet {
  final Color baseColor;
  final Color mainColor;
  final Color overColor;
  final Color shortColor;
  final Color inactiveColor;

  _ColorSet(
      this.baseColor,
      this.mainColor,
      this.overColor,
      this.shortColor,
      this.inactiveColor
  );
}