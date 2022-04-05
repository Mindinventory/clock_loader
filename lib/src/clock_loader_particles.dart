import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'clock_loader_main_handle.dart';
import 'config.dart';
import 'const.dart';

enum ShapeOfParticlesEnum { circle, square }

class ClockLoaderModel {
  /// This will give the choice for particles shape.
  ShapeOfParticlesEnum? shapeOfParticles;

  /// This will give the mainHandle color.
  Color? mainHandleColor;

  /// This will give the particles color.
  Color? particlesColor;

  ClockLoaderModel({
    Key? key,
    this.shapeOfParticles = ShapeOfParticlesEnum.square,
    this.mainHandleColor = Colors.white,
    this.particlesColor = Colors.white,
  });
}

class ClockLoader extends StatefulWidget {
  final ClockLoaderModel clockLoaderModel;

  const ClockLoader({
    Key? key,
    required this.clockLoaderModel,
  }) : super(key: key);
  @override
  _ClockSimplePathState createState() => _ClockSimplePathState();
}

class _ClockSimplePathState extends State<ClockLoader>
    with TickerProviderStateMixin {
  List<Path> listPath = [];
  List<Animation<double>> listOfAnimations = [];
  List<AnimationController> listOfAnimationController = [];

  @override
  void dispose() {
    ///cancel the timer and dispose the animation controller
    _disposeAndClearControllerList();
    super.dispose();
  }

  void _disposeAndClearControllerList() {
    for (var element in listOfAnimationController) {
      element.stop();
      element.dispose();
    }
    TimerManager().mainTimer?.cancel();
    listOfAnimationController.clear();
    listOfAnimations.clear();
  }

  @override
  void initState() {
    super.initState();

    ///we used timer here to manage smoothness of the animation for refresh rate
    TimerManager().startTimer(
      timerType: TimerType.milliseconds,
      timerCallback: () {
        if(mounted) {
          setState(() {});
        }
      },
    );

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      listPath = listOfOuterCircleOffset();
      fillAnimationController();
    });
  }

  Future<void> fillAnimationController() async {
    ///just fill the AnimationController
    for (int i = 0; i < numberOfSquare; i++) {
      listOfAnimationController.add(
        AnimationController(
          vsync: this,
          duration: Duration(
            milliseconds: neededDelayForSquareAnim.toInt(),
          ),
        ),
      );
      listOfAnimations.add(
        Tween(begin: 0.0, end: 1.0).animate(
          listOfAnimationController[i],
        ),
      );
    }

    ///add status listener
    listOfAnimationController[numberOfSquare - 1].addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          for (int i = 0; i < numberOfSquare; i++) {
            listOfAnimationController[i].reverse();
            await Future.delayed(
              Duration(
                milliseconds: neededDelayForSquareAnim.toInt(),
              ),
            );
          }
        } else if (status == AnimationStatus.reverse) {
        } else if (status == AnimationStatus.dismissed) {
          for (int i = 0; i < numberOfSquare; i++) {
            listOfAnimationController[i].forward();
            await Future.delayed(
              Duration(
                milliseconds: neededDelayForSquareAnim.toInt(),
              ),
            );
          }
        }
      },
    );

    ///starting first animation from here
    for (int i = 0; i < numberOfSquare; i++) {
      mainHand -= mainHandOneSquarePartHeight;
      listOfAnimationController[i].forward();
      await Future.delayed(
        Duration(
          milliseconds: neededDelayForSquareAnim.toInt(),
        ),
      );
    }

    ///manage mainHandle size from here
    for (int i = 0; i < numberOfSquare; i++) {
      listOfAnimationController[i].addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
        } else if (status == AnimationStatus.reverse) {
          mainHand += mainHandOneSquarePartHeight;
        } else if (status == AnimationStatus.forward) {
          mainHand -= mainHandOneSquarePartHeight;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.rotate(
        angle: -pi / 2,
        child: SizedBox(
          width: loaderWidth,
          height: loaderHeight,
          child: Stack(
            children: [
              Center(
                child: ClockLoaderView(
                  clockLoaderModel: widget.clockLoaderModel,
                ),
              ),
              ...listOfAnimatedSquare(
                clockLoaderModel: widget.clockLoaderModel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///this will satisfy the requirement of particles painting
class AnimatedShapePainter extends CustomPainter {
  AnimatedShapePainter({
    required this.animation,
    required this.path,
    required this.clockLoaderModel,
  });

  final Animation animation;
  final Path path;
  final ClockLoaderModel clockLoaderModel;

  ///paint brush for particles
  @override
  void paint(Canvas canvas, Size size) {
    final mainHandConvertedValueRelativeTo0And1 = mainHand / mainHandConverterValue;
    final color = (animation.value == 0 || mainHandConvertedValueRelativeTo0And1 > animation.value)
        ? Colors.transparent
        : clockLoaderModel.particlesColor;
    var paint = Paint()
      ..color = color ?? Colors.white
      ..style = PaintingStyle.fill;

    final x1 = calculate(animation.value, path)?.dx ?? 0;
    final y1 = calculate(animation.value, path)?.dy ?? 0;
    clockLoaderModel.shapeOfParticles == ShapeOfParticlesEnum.square
        ? canvas.drawRect(Offset(x1, y1) & const Size(squareSize, squareSize), paint)
        : canvas.drawCircle(Offset(x1, y1), 5.2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  ///this represent calculation of offset from path metrics
  Offset? calculate(value, Path path) {
    PathMetrics pathMetrics = path.computeMetrics();
    PathMetric pathMetric = pathMetrics.elementAt(0);
    value = pathMetric.length * value;
    Tangent? pos = pathMetric.getTangentForOffset(value);
    return pos?.position;
  }
}

///this will satisfy the requirement of path painting
class PathPainter extends CustomPainter {
  Path path;
  PathPainter(this.path);

  ///paint brush for particles path
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

/// extension to manage the clean code
extension Ext on _ClockSimplePathState {
  ///generate the all particles widget and make one list of that
  List<Widget> listOfAnimatedSquare(
      {required ClockLoaderModel clockLoaderModel}) {
    List<Widget> listOfWidget = [];

    listPath.mapIndexed((index, pathElement) {
      listOfWidget.add(
        CustomPaint(
          painter: AnimatedShapePainter(
              animation: listOfAnimations[index],
              path: pathElement,
              clockLoaderModel: clockLoaderModel),
          child: Container(),
        ),
      );
    }).toList();

    return listOfWidget;
  }

  ///generate the Outer Circle Offsets make one list of that
  List<Path> listOfOuterCircleOffset() {
    var innerCircleRadius = radius - (radius / 3);
    var quadraticCircleRadius = radius - (radius / 1.5);
    List<Path> listPath = [];

    var initSectors = getSectionsCoordinatesInCircle(
        const Offset(radius, radius),
        quadraticCircleRadius,
        (numberOfSquare * 2));

    ///this evenOffsets tens for the each middle offset of total count
    ///So suppose total is 24 then middle should be 12
    ///we require this evenOffsets to make a curve on path
    ///we use this offsets in quadraticBezierTo property of Path.
    List<Offset> evenOffsets = [];

    initSectors.mapIndexed((index, element) {
      if (index % 2 != 0) {
        evenOffsets.add(element);
      }
    }).toList();

    int index = -1;
    for (double i = 0; i < 360; i += 30) {
      index += 1;
      var endPointX2 = radius + (innerCircleRadius * cos(i * pi / 180));
      var endPointY2 = radius + (innerCircleRadius * sin(i * pi / 180));
      Path path = Path();
      path.moveTo(radius, radius);
      path.quadraticBezierTo(
          evenOffsets[index].dx, evenOffsets[index].dy, endPointX2, endPointY2);
      listPath.add(path);
    }

    return listPath;
  }
}
