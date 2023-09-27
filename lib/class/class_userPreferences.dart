import 'package:flutter/material.dart';

import 'abstract_Place.dart';

/// handle user preferences. The values written here are default values
/// the correct values are loaded in loadSettings() from sharedPreferences
class UserPreferences {
  bool notificationWithExtreme = true;
  bool notificationWithSevere = true;
  bool notificationWithModerate = true;
  bool notificationWithMinor = false;

  bool shouldNotifyGeneral = true;

  bool showStatusNotification = true;

  Map<String, bool> notificationEventsSettings = new Map();

  bool showExtendedMetaData = false; // show more tags in WarningDetailView
  ThemeMode selectedTheme = ThemeMode.system;
  double frequencyOfAPICall = 15;
  double frequencyOfLocationUpdate = 90;

  int startScreen = 0;
  double warningFontSize = 14;
  bool showWelcomeScreen = true;
  String sortWarningsBy = "severity";
  bool updateAvailable = false;
  bool showAllWarnings = false;
  bool areWarningsFromCache = false;

  String versionNumber = "0.6.0-alpha_4 "; // shown in the about view

  bool activateAlertSwiss = false;
  bool isFirstStart = true;

  bool warningsForCurrentLocation = false;

  Place? currentPlace;
}