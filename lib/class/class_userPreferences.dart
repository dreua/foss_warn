import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foss_warn/themes/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enums/Severity.dart';
import '../enums/WarningSource.dart';
import 'class_notificationPreferences.dart';

/// handle user preferences. The values written here are default values
/// the correct values are loaded in loadSettings() from sharedPreferences
class UserPreferences {
  static final UserPreferences _instance = UserPreferences._internal();
  static late SharedPreferences _preferences;

  // construction which allows to create new instances of the class only from inside
  UserPreferences._internal();

  factory UserPreferences() => _instance;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Private generic method for retrieving data from shared preferences
  dynamic _getData(String key) {
    // Retrieve data from shared preferences
    var value = _preferences.get(key);

    // Easily log the data that we retrieve from shared preferences
    print('Retrieved $key: $value');

    // Return the data that we retrieve from shared preferences
    return value;
  }

  // Private method for saving data to shared preferences
  void _saveData(String key, dynamic value) {
    // Easily log the data that we save to shared preferences
    print('Saving $key: $value');

    // Save data to shared preferences
    if (value is String) {
      _preferences.setString(key, value);
    } else if (value is int) {
      _preferences.setInt(key, value);
    } else if (value is double) {
      _preferences.setDouble(key, value);
    } else if (value is bool) {
      _preferences.setBool(key, value);
    } else if (value is List<String>) {
      _preferences.setStringList(key, value);
    }
  }

  bool shouldNotifyGeneral = true;

  bool showStatusNotification = true;

  @deprecated
  Map<String, bool> notificationEventsSettings = new Map();
  // to save the user settings for which source
  // the user would like to be notified
  List<NotificationPreferences> _notificationSourceSettings =
      _getDefaultValueForNotificationSourceSettings();

  List<NotificationPreferences> get notificationSourceSettings {
    _preferences.remove("notificationSourceSettings");
    dynamic storeData = _getData('notificationSourceSettings');
    if(storeData != null)  {
      List<NotificationPreferences> temp = [];
      List<dynamic> data = jsonDecode(storeData);
      for (int i = 0; i < data.length; i++) {
        temp.add(NotificationPreferences.fromJson(data[i]));
      }
      return temp;
    } else {
      return _getDefaultValueForNotificationSourceSettings();
    }
  }


  set notificationSourceSettings(List<NotificationPreferences> value) =>
      _saveData('notificationSourceSettings', jsonEncode(value));

  static List<NotificationPreferences>
      _getDefaultValueForNotificationSourceSettings() {
    List<NotificationPreferences> temp = [];

    for (WarningSource source in WarningSource.values) {
      if (source == WarningSource.dwd || source == WarningSource.lhp) {
        temp.add(NotificationPreferences(
            warningSource: source, notificationLevel: Severity.severe));
      } else {
        temp.add(NotificationPreferences(
            warningSource: source, notificationLevel: Severity.minor));
      }
    }
    return temp;
  }

  bool showExtendedMetaData = false; // show more tags in WarningDetailView
  ThemeMode selectedThemeMode = ThemeMode.system;
  ThemeData selectedLightTheme = greenLightTheme;
  ThemeData selectedDarkTheme = greenDarkTheme;
  double frequencyOfAPICall = 15;

  int startScreen = 0;
  double warningFontSize = 14;
  bool showWelcomeScreen = true;
  String sortWarningsBy = "severity";
  bool updateAvailable = false;
  bool showAllWarnings = false;
  bool areWarningsFromCache = false;

  String versionNumber = "0.6.2"; // shown in the about view

  bool activateAlertSwiss = false;
  bool isFirstStart = true;

  Duration networkTimeout = Duration(seconds: 8);

  List<ThemeData> availableLightThemes = [
    greenLightTheme,
    orangeLightTheme,
    purpleLightTheme,
    blueLightTheme,
    yellowLightTheme,
    indigoLightTheme
  ];
  List<ThemeData> availableDarkThemes = [
    greenDarkTheme,
    orangeDarkTheme,
    purpleDarkTheme,
    yellowDarkTheme,
    blueDarkTheme,
    greyDarkTheme
  ];
}
