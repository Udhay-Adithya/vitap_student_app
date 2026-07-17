Map<String, String> getWeatherDescription(int wmoCode) {
  final Map<String, Map<String, Map<String, String>>> wmoCodes = {
    '0': {
      'day': {
        'description': 'Sunny',
        'asset': 'assets/weather_icons/sun-hot.json',
      },
      'night': {
        'description': 'Clear',
        'asset': 'assets/weather_icons/starry-night.json',
      },
    },
    '1': {
      'day': {
        'description': 'Mainly Sunny',
        'asset': 'assets/weather_icons/clear-day.json',
      },
      'night': {
        'description': 'Mainly Clear',
        'asset': 'assets/weather_icons/clear-night.json',
      },
    },
    '2': {
      'day': {
        'description': 'Partly Cloudy',
        'asset': 'assets/weather_icons/partly-cloudy-day.json',
      },
      'night': {
        'description': 'Partly Cloudy',
        'asset': 'assets/weather_icons/partly-cloudy-night.json',
      },
    },
    '3': {
      'day': {
        'description': 'Cloudy',
        'asset': 'assets/weather_icons/partly-cloudy-day.json',
      },
      'night': {
        'description': 'Cloudy',
        'asset': 'assets/weather_icons/partly-cloudy-night.json',
      },
    },
    '5': {
      'day': {
        'description': 'Haze',
        'asset': 'assets/weather_icons/haze-day.json',
      },
      'night': {
        'description': 'Haze',
        'asset': 'assets/weather_icons/haze-night.json',
      },
    },
    '45': {
      'day': {
        'description': 'Foggy',
        'asset': 'assets/weather_icons/fog-day.json',
      },
      'night': {
        'description': 'Foggy',
        'asset': 'assets/weather_icons/fog-night.json',
      },
    },
    '48': {
      'day': {
        'description': 'Rime Fog',
        'asset': 'assets/weather_icons/fog.json',
      },
      'night': {
        'description': 'Rime Fog',
        'asset': 'assets/weather_icons/fog.json',
      },
    },
    '51': {
      'day': {
        'description': 'Light Drizzle',
        'asset': 'assets/weather_icons/partly-cloudy-day-drizzle.json',
      },
      'night': {
        'description': 'Light Drizzle',
        'asset': 'assets/weather_icons/partly-cloudy-night-drizzle.json',
      },
    },
    '53': {
      'day': {
        'description': 'Drizzle',
        'asset': 'assets/weather_icons/drizzle.json',
      },
      'night': {
        'description': 'Drizzle',
        'asset': 'assets/weather_icons/drizzle.json',
      },
    },
    '55': {
      'day': {
        'description': 'Heavy Drizzle',
        'asset': 'assets/weather_icons/drizzle.json',
      },
      'night': {
        'description': 'Heavy Drizzle',
        'asset': 'assets/weather_icons/drizzle.json',
      },
    },
    '56': {
      'day': {
        'description': 'Light Freezing Drizzle',
        'asset': 'assets/weather_icons/partly-cloudy-day-sleet.json',
      },
      'night': {
        'description': 'Light Freezing Drizzle',
        'asset': 'assets/weather_icons/partly-cloudy-day-sleet.json',
      },
    },
    '57': {
      'day': {
        'description': 'Freezing Drizzle',
        'asset': 'assets/weather_icons/partly-cloudy-day-sleet.json',
      },
      'night': {
        'description': 'Freezing Drizzle',
        'asset': 'assets/weather_icons/partly-cloudy-day-sleet.json',
      },
    },
    '61': {
      'day': {
        'description': 'Light Rain',
        'asset': 'assets/weather_icons/partly-cloudy-day-rain.json',
      },
      'night': {
        'description': 'Light Rain',
        'asset': 'assets/weather_icons/partly-cloudy-night-rain.json',
      },
    },
    '63': {
      'day': {'description': 'Rain', 'asset': 'assets/weather_icons/rain.json'},
      'night': {
        'description': 'Rain',
        'asset': 'assets/weather_icons/rain.json',
      },
    },
    '65': {
      'day': {
        'description': 'Heavy Rain',
        'asset': 'assets/weather_icons/rain.json',
      },
      'night': {
        'description': 'Heavy Rain',
        'asset': 'assets/weather_icons/rain.json',
      },
    },
    '66': {
      'day': {
        'description': 'Light Freezing Rain',
        'asset': 'assets/weather_icons/partly-cloudy-day-sleet.json',
      },
      'night': {
        'description': 'Light Freezing Rain',
        'asset': 'assets/weather_icons/partly-cloudy-night-sleet.json',
      },
    },
    '67': {
      'day': {
        'description': 'Freezing Rain',
        'asset': 'assets/weather_icons/sleet.json',
      },
      'night': {
        'description': 'Freezing Rain',
        'asset': 'assets/weather_icons/sleet.json',
      },
    },
    '71': {
      'day': {
        'description': 'Light Snow',
        'asset': 'assets/weather_icons/partly-cloudy-day-snow.json',
      },
      'night': {
        'description': 'Light Snow',
        'asset': 'assets/weather_icons/partly-cloudy-night-snow.json',
      },
    },
    '73': {
      'day': {'description': 'Snow', 'asset': 'assets/weather_icons/snow.json'},
      'night': {
        'description': 'Snow',
        'asset': 'assets/weather_icons/snow.json',
      },
    },
    '75': {
      'day': {
        'description': 'Heavy Snow',
        'asset': 'assets/weather_icons/snow.json',
      },
      'night': {
        'description': 'Heavy Snow',
        'asset': 'assets/weather_icons/snow.json',
      },
    },
    '77': {
      'day': {
        'description': 'Snow Grains',
        'asset': 'assets/weather_icons/snow.json',
      },
      'night': {
        'description': 'Snow Grains',
        'asset': 'assets/weather_icons/snow.json',
      },
    },
    '80': {
      'day': {
        'description': 'Light Showers',
        'asset': 'assets/weather_icons/partly-cloudy-day-rain.json',
      },
      'night': {
        'description': 'Light Showers',
        'asset': 'assets/weather_icons/partly-cloudy-night-rain.json',
      },
    },
    '81': {
      'day': {
        'description': 'Showers',
        'asset': 'assets/weather_icons/rain.json',
      },
      'night': {
        'description': 'Showers',
        'asset': 'assets/weather_icons/rain.json',
      },
    },
    '82': {
      'day': {
        'description': 'Heavy Showers',
        'asset': 'assets/weather_icons/rain.json',
      },
      'night': {
        'description': 'Heavy Showers',
        'asset': 'assets/weather_icons/rain.json',
      },
    },
    '85': {
      'day': {
        'description': 'Light Snow Showers',
        'asset': 'assets/weather_icons/snow.json',
      },
      'night': {
        'description': 'Light Snow Showers',
        'asset': 'assets/weather_icons/snow.json',
      },
    },
    '86': {
      'day': {
        'description': 'Snow Showers',
        'asset': 'assets/weather_icons/snow.json',
      },
      'night': {
        'description': 'Snow Showers',
        'asset': 'assets/weather_icons/snow.json',
      },
    },
    '95': {
      'day': {
        'description': 'Thunderstorm',
        'asset': 'assets/weather_icons/thunderstorms-day.json',
      },
      'night': {
        'description': 'Thunderstorm',
        'asset': 'assets/weather_icons/thunderstorms-night.json',
      },
    },
    '96': {
      'day': {
        'description': 'Light Thunderstorms With Hail',
        'asset': 'assets/weather_icons/thunderstorms.json',
      },
      'night': {
        'description': 'Light Thunderstorms With Hail',
        'asset': 'assets/weather_icons/thunderstorms.json',
      },
    },
    '99': {
      'day': {
        'description': 'Thunderstorm With Hail',
        'asset': 'assets/weather_icons/thunderstorms.json',
      },
      'night': {
        'description': 'Thunderstorm With Hail',
        'asset': 'assets/weather_icons/thunderstorms.json',
      },
    },
  };

  final DateTime now = DateTime.now();
  final bool isDayTime = now.hour > 6 && now.hour < 20;

  final String timeOfDay = isDayTime ? 'day' : 'night';
  final String description =
      wmoCodes[wmoCode.toString()]?[timeOfDay]?['description'] ??
      'Unknown $wmoCode';
  final String assetPath =
      wmoCodes[wmoCode.toString()]?[timeOfDay]?['asset'] ??
      'assets/weather_icons/not-available.json';

  return {'description': description, 'assetPath': assetPath};
}
