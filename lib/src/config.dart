import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'dart:ui';

enum TimerType { minutes, seconds, milliseconds, microseconds }

///timer manager class which satisfy the requirement to access the main object from any where of project.
class TimerManager {
  static final TimerManager _singleton = TimerManager._internal();

  factory TimerManager() {
    return _singleton;
  }

  TimerManager._internal();

  Timer? mainTimer;

  void startTimer(
      {required TimerType timerType, required VoidCallback timerCallback}) {
    switch (timerType) {
      case TimerType.minutes:
        mainTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
          timerCallback();
        });
        break;

      case TimerType.seconds:
        mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          timerCallback();
        });
        break;

      case TimerType.milliseconds:
        mainTimer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
          timerCallback();
        });
        break;

      case TimerType.microseconds:
        mainTimer = Timer.periodic(const Duration(microseconds: 1), (timer) {
          timerCallback();
        });
        break;
    }
  }
}

///LoaderConfig class which satisfy the requirement to access the configuration properties of clockLoader from any where of project.
class LoaderConfig {

  static final LoaderConfig _singleton = LoaderConfig._internal();
  factory LoaderConfig() {
    return _singleton;
  }
  LoaderConfig._internal();

  late double mainHand;
  late int numberOfSquare;
  late double mainHandOneSquarePartHeight;
  late int wholeRoundAnimMilliSec;
  late double neededDelayForSquareAnim;
  late double mainHandConverterValue;

  void initialize() {

    mainHand = 100.0;
    numberOfSquare = 12;
    mainHandOneSquarePartHeight = mainHand / numberOfSquare;

    wholeRoundAnimMilliSec = 4008;
    neededDelayForSquareAnim = wholeRoundAnimMilliSec / numberOfSquare;

    mainHandConverterValue = mainHand;
  }
}

///calculate the list of offset around the circle border
List<Offset> getSectionsCoordinatesInCircle(
    Offset center, double radius, int sections) {
  var intervalAngle = (pi * 2) / sections;
  return List<int>.generate(sections, (int index) => index).map((i) {
    var radians = (pi * 2) + (intervalAngle * i);
    return radiansToCoordinates(center, radians, radius);
  }).toList();
}

///convert the calculated radians to coordinates
Offset radiansToCoordinates(Offset center, double radians, double radius) {
  var dx = center.dx + radius * cos(radians);
  var dy = center.dy + radius * sin(radians);
  return Offset(dx, dy);
}
