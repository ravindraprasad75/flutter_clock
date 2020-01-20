class WeatherIconMappings {
  static Map<String, String> _weatherIcons = {
    'cloudy': 'wi-cloudy',
    'foggy': 'wi-fog',
    'rainy': 'wi-rain',
    'snowy': 'wi-snow',
    'sunny': 'wi-day-sunny',
    'thunderstorm': 'wi-thunderstorm',
    'windy': 'wi-windy',
  };

  static getWeatherIcon(type){
    return _weatherIcons[type];
  }
}