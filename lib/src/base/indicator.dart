import 'package:arna/arna.dart';

/// A circular progress indicator, which spins to indicate that the application
/// is busy.
///
/// There are two kinds of circular progress indicators:
///
///  * _Determinate_. Determinate progress indicators have a specific value at
///    each point in time, and the value should increase monotonically from 0.0
///    to 1.0, at which time the indicator is complete. To create a determinate
///    progress indicator, use a non-null [value] between 0.0 and 1.0.
///  * _Indeterminate_. Indeterminate progress indicators do not have a specific
///    value at each point in time and instead indicate that progress is being
///    made without indicating how much progress remains. To create an
///    indeterminate progress indicator, use a null [value].
class ArnaProgressIndicator extends StatefulWidget {
  /// Creates a circular progress indicator.
  const ArnaProgressIndicator({
    Key? key,
    this.value,
    this.size = Styles.indicatorSize,
    this.accentColor,
  }) : super(key: key);

  /// If non-null, the value of this progress indicator.
  ///
  /// A value of 0.0 means no progress and 1.0 means that progress is complete.
  /// The value will be clamped to be in the range 0.0-1.0.
  ///
  /// If null, this progress indicator is indeterminate, which means the
  /// indicator displays a predetermined animation that does not indicate how
  /// much actual progress is being made.
  final double? value;

  /// The progress indicator's size.
  final double? size;

  /// The progress indicator's background color.
  final Color? accentColor;

  @override
  _ArnaProgressIndicatorState createState() => _ArnaProgressIndicatorState();
}

class _ArnaProgressIndicatorState extends State<ArnaProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Styles.indicatorDuration,
      vsync: this,
    );
    if (widget.value == null) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double? value = widget.value;
    const pi = 3.1415926535897932;
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return CustomPaint(
            painter: _ProgressPainter(
              color: widget.accentColor ?? ArnaTheme.of(context).accentColor,
              value: widget.value == null
                  ? _controller.value * 2 * pi
                  : value!.clamp(0.0, 1.0) * (pi * 2.0 - .001),
              offset: widget.value == null,
            ),
          );
        },
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final Color color;
  final double value;
  final bool offset;

  _ProgressPainter({
    required this.color,
    required this.value,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      center,
      size.width / 4,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = color
        ..strokeWidth = size.width / 4,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 4),
      (3.1415926535897932) * 1.5 + (offset ? value : 0),
      value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..color = ArnaColors.color36
        ..strokeWidth = size.width / 8,
    );
  }

  @override
  bool shouldRepaint(_ProgressPainter oldPainter) {
    return oldPainter.color != color || oldPainter.value != value;
  }
}
