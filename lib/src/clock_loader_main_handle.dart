import 'dart:math';

import 'package:flutter/material.dart';

import 'clock_loader_particles.dart';
import 'const.dart';

class ClockLoaderView extends StatefulWidget {
  const ClockLoaderView({
    Key? key,
    required this.clockLoaderModel,
  }) : super(key: key);

  final ClockLoaderModel clockLoaderModel;
  @override
  _ClockLoaderViewState createState() => _ClockLoaderViewState();
}

class _ClockLoaderViewState extends State<ClockLoaderView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    ///initialize the animation controller and Tween to take required output value as rounded rotation of mainHandle
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: wholeRoundAnimMilliSec),
    )
      ..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          _animationController.reset();
        } else if (status == AnimationStatus.dismissed) {
          await Future.delayed(const Duration(milliseconds: 20));
          _animationController.forward();
        }
      })
      ..forward();

    _animation = Tween(begin: 0.0, end: 360).animate(_animationController);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: loaderWidth,
      height: loaderHeight,
      child: CustomPaint(
        painter: ClockPainter(
          clockLoaderModel: widget.clockLoaderModel,
          animation: _animation,
        ),
      ),
    );
  }
}

///this will satisfy the requirement of mainHand painting
class ClockPainter extends CustomPainter {
  final Animation animation;
  ClockLoaderModel clockLoaderModel;

  ClockPainter({required this.animation, required this.clockLoaderModel});

  @override
  void paint(Canvas canvas, Size size) {
    var centerFromX = size.width / 2;
    var centerFromY = size.height / 2;
    var center = Offset(centerFromX, centerFromY);

    ///paint brush for mainHand
    var minHandBrush = Paint()
      ..color = clockLoaderModel.mainHandleColor ?? Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap =
          clockLoaderModel.shapeOfParticles == ShapeOfParticlesEnum.square
              ? StrokeCap.square
              : StrokeCap.round
      ..strokeWidth = squareSize;

    ///calculate the required dx and dy offset for mainHandle
    var mainHandX =
        centerFromX + (mainHand * cos(animation.value * 1 * pi / 180));
    var mainHandY =
        centerFromY + (mainHand * sin(animation.value * 1 * pi / 180));
    canvas.drawLine(center, Offset(mainHandX, mainHandY), minHandBrush);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
