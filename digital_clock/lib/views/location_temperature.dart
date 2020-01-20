import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

import '../weather_icons.dart';

class LocationTemperatureView extends StatelessWidget {

  final String location;
  final String temperature;
  final String weather;
  LocationTemperatureView({
    @required this.location,
    @required this.temperature,
    @required this.weather
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: MediaQuery.of(context).size.width / 4,
                  height: MediaQuery.of(context).size.width / 10,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: FittedBox(
                          child: Row(
                            children: <Widget>[
                              BoxedIcon(
                                WeatherIcons.fromString(
                                  WeatherIconMappings.getWeatherIcon(weather),
                                ),
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                location,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            FittedBox(
                              child: BoxedIcon(
                                WeatherIcons.thermometer,
                                color: Colors.white,
                              ),
                            ),
                            FittedBox(
                              child: Text(
                                temperature,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
  }
}