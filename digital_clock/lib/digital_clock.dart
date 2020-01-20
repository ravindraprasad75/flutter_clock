// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:digital_clock/timezone_map_mapping.dart';
import 'package:digital_clock/views/date_time.dart';
import 'package:digital_clock/views/location_temperature.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/vec2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// You can do better than this!
class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> with FlareController {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      // _timer = Timer(
      //   Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
    });
  }

  @override
  Widget build(BuildContext context) {
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final day = DateFormat('EEE, MMM d').format(_dateTime);
    final defaultStyle = TextStyle(
      color: Colors.white,
      fontFamily: 'NoticiaText',
    );

    return Container(
      color: Colors.black,
      child: Center(
        child: DefaultTextStyle(
          style: defaultStyle,
          child: Stack(
            children: <Widget>[
              FlareActor(
                'assets/Earth_Day_Night_View.flr',
                alignment: Alignment.center,
                fit: BoxFit.cover,
                animation: 'day_night',
                controller: this,
              ),
              DateTimeView(
                day: day,
                hour: hour,
                minute: minute,
              ),
              LocationTemperatureView(
                weather: widget.model.weatherString,
                location: widget.model.location,
                temperature: widget.model.temperatureString,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ActorAnimation mainAnimation;
  ActorNode dayView;
  ActorNode nightView;
  ActorNode wholeMoon;
  ActorNode moonEclipse;
  ActorNode moonEclipse2;
  ActorNode moonPhaseNode;
  ActorNode moonPhase2Node;

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    // Map 24 minutes Fultter animation to 24hrs Day animation
    double hours = double.parse(DateFormat('HH').format(_dateTime));
    double minutes = double.parse(DateFormat('mm').format(_dateTime));
    hours += 6;
    hours %= 24;
    mainAnimation.apply(hours + (minutes / 60), artboard, 1.0);

    // Show Map view of current timezone
    int timezoneHoursDiff = _dateTime.timeZoneOffset.inHours % 12;
    int xMovebY = TimezoneToMap.timezoneToMap[timezoneHoursDiff.toString()];
    Vec2D moveBy = new Vec2D.fromValues(xMovebY.toDouble(), 0);
    dayView.translation = Vec2D.add(Vec2D(), dayView.translation, moveBy);
    nightView.translation = Vec2D.add(Vec2D(), nightView.translation, moveBy);

    if (hours < 15) {
      getMoonPhase();
    }
    return true;
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    mainAnimation = artboard.getAnimation('day_night');
    dayView = artboard.getNode('earth_day');
    nightView = artboard.getNode('nightmap');
    wholeMoon = artboard.getNode('sat_moon');
    moonEclipse = artboard.getNode('moon_eclipse');
    moonEclipse2 = artboard.getNode('moon_eclipse_2');
    moonPhaseNode = artboard.getNode('Phase_1');
    moonPhase2Node = artboard.getNode('phase_2');
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  getMoonPhase() {
    int year = int.parse(DateFormat('yyyy').format(_dateTime));
    int month = int.parse(DateFormat('MM').format(_dateTime));
    // If the month is January or February, subtract 1 from the year and add 12 to the month
    if (month < 3) {
      year--;
      month += 12;
    }
    int day = int.parse(DateFormat('dd').format(_dateTime));
    int a = year ~/ 100;
    int b = a ~/ 4;
    int c = 2 - a + b;
    int d = (365.25 * (year + 4716)).toInt();
    int e = (30.6001 * (month + 1)).toInt();
    double jd = (c + day + d + e) - 1524.5;
    double daysSinceNewMoon = jd - 2451549.5;
    double newMoons = daysSinceNewMoon / 29.53;
    double fraction = newMoons % 1;

    int moonPhase = (fraction * 30).round();
    final fullMoonLenth = 220;
    final momentByDate = 1 / 15;

    bool isIncreasing = moonPhase > 22 || moonPhase < 8;
    bool shouldRotate = moonPhase > 15;

    if (moonPhase > 15) {
      moonPhase = 30 - moonPhase;
    }
    double moonViewTranslation = (fullMoonLenth * momentByDate * moonPhase);
    double originOffset = 33.5;
    if (isIncreasing) {
      Vec2D moveBy =
          new Vec2D.fromValues(originOffset - moonViewTranslation, 24);
      moonEclipse.translation = moveBy;

      moonPhase2Node.opacity = 0;
      moonPhaseNode.opacity = 1;

      moonEclipse.scaleY = 1.01;
      moonEclipse.scaleX = 1.01;
      if (moonPhase == 7) {
        moonEclipse.scaleY = 7;
      } else if (moonPhase < 7 && moonPhase > 3) {
        moonEclipse.scaleY = 2 * moonPhase / 7;
      }
      if (shouldRotate) {
        wholeMoon.rotation = 135.0;
      } else {
        wholeMoon.rotation = 0.0;
      }
    } else {
      moonViewTranslation = fullMoonLenth - moonViewTranslation;
      if (moonPhase != 15) {
        moonViewTranslation =
            moonViewTranslation - (moonViewTranslation * 3) / moonPhase;
      }
      Vec2D moveBy =
          new Vec2D.fromValues(originOffset + moonViewTranslation, 24);
      moonEclipse2.translation = moveBy;
      moonPhase2Node.opacity = 1;
      moonPhaseNode.opacity = 0;
      if (moonPhase < 12) {
        moonEclipse.scaleY = 3 * (15 - moonPhase) / 7;
      }
      if (shouldRotate) {
        wholeMoon.rotation = 0.0;
      } else {
        wholeMoon.rotation = 135.0;
      }
    }
  }
}
