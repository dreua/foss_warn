import 'dart:convert';
import 'package:foss_warn/class/class_notificationPreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import '../class/class_AlertSwissPlace.dart';
import '../class/class_NinaPlace.dart';

import '../class/class_userPreferences.dart';
import 'listHandler.dart';
import '../main.dart';

// My Places
saveMyPlacesList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("MyPlacesListAsJson", jsonEncode(myPlaceList));
}

loadMyPlacesList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  if (preferences.containsKey("MyPlacesListAsJson")) {
    List<dynamic> data =
        jsonDecode(preferences.getString("MyPlacesListAsJson")!);
    myPlaceList.clear();
    for (int i = 0; i < data.length; i++) {
      print(data[i].toString());
      if (data[i].toString().contains("geocode")) {
        // print("Nina Place");
        myPlaceList.add(NinaPlace.fromJson(data[i]));
      } else if (data[i].toString().contains("shortName")) {
        //@todo think about better solution
        // print("alert swiss place");
        myPlaceList.add(AlertSwissPlace.fromJson(data[i]));
      }
    }
    print(myPlaceList);
  }
}

saveGeocodes(String jsonFile) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  print("save geocodes");
  preferences.setString("geocodes", jsonFile);
}

Future<dynamic> loadGeocode() async {
  print("load geocodes from storage");
  SharedPreferences preferences = await SharedPreferences.getInstance();
  // preferences.remove("geocodes");
  if (preferences.containsKey("geocodes")) {
    print("we have some geocodes");
    var result = preferences.getString("geocodes")!;
    return jsonDecode(result);
  } else {
    print("geocodes are not saved");
    return null;
  }
}

/// load the time when the API could be called successfully the last time.
/// used in the status notification
Future<String> loadLastBackgroundUpdateTime() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.containsKey("lastBackgroundUpdateTime")) {
    return preferences.getString("lastBackgroundUpdateTime")!;
  }
  return "";
}

/// saved the time when the API could be called successfully the last time.
/// used in the status notification
void saveLastBackgroundUpdateTime(String time) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("lastBackgroundUpdateTime", time);
}

// Settings
saveSettings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool(
      "notificationGeneral", UserPreferences().shouldNotifyGeneral);
  preferences.setInt("startScreen", UserPreferences().startScreen);
  preferences.setBool(
      "showExtendedMetaData", UserPreferences().showExtendedMetaData);
  preferences.setDouble("warningFontSize", UserPreferences().warningFontSize);
  preferences.setBool("showWelcomeScreen", UserPreferences().showWelcomeScreen);
  preferences.setString(
      "sortWarningsBy", UserPreferences().sortWarningsBy.toString());
  preferences.setBool(
      "showStatusNotification", UserPreferences().showStatusNotification);
  preferences.setDouble(
      "frequencyOfAPICall", UserPreferences().frequencyOfAPICall);
  preferences.setString(
      "selectedThemeMode", UserPreferences().selectedThemeMode.toString());
  preferences.setInt(
      "selectedLightTheme",
      UserPreferences().availableLightThemes
          .indexOf(UserPreferences().selectedLightTheme));
  preferences.setInt(
      "selectedDarkTheme",
      UserPreferences().availableDarkThemes
          .indexOf(UserPreferences().selectedDarkTheme));
  preferences.setBool("showAllWarnings", UserPreferences().showAllWarnings);
  /*preferences.setString("notificationSourceSettings",
      jsonEncode(UserPreferences().notificationSourceSettings));*/
  preferences.setBool("activateAlertSwiss", UserPreferences().activateAlertSwiss);
  print("Settings saved");
}

saveETags() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("mowasEtag", appState.mowasETag);
  preferences.setString("biwappEtag", appState.biwappETag);
  preferences.setString("katwarnEtag", appState.katwarnETag);
  preferences.setString("dwdEtag", appState.dwdETag);
  preferences.setString("lhpEtag", appState.lhpETag);
  print("etags saved");
}

loadETags() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.containsKey("mowasEtag")) {
    String temp = preferences.getString("mowasEtag")!;
    appState.mowasETag = temp;
  }
  if (preferences.containsKey("biwappEtag")) {
    String temp = preferences.getString("biwappEtag")!;
    appState.biwappETag = temp;
  }
  if (preferences.containsKey("katwarnEtag")) {
    String temp = preferences.getString("katwarnEtag")!;
    appState.katwarnETag = temp;
  }
  if (preferences.containsKey("dwdEtag")) {
    String temp = preferences.getString("dwdEtag")!;
    appState.dwdETag = temp;
  }
  if (preferences.containsKey("lhpEtag")) {
    String temp = preferences.getString("lhpEtag")!;
    appState.lhpETag = temp;
  }
}

loadSettings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  if (preferences.containsKey("notificationGeneral")) {
    UserPreferences().shouldNotifyGeneral =
        preferences.getBool("notificationGeneral")!;
  }
  if (preferences.containsKey("startScreen")) {
    UserPreferences().startScreen = preferences.getInt("startScreen")!;
  }
  if (preferences.containsKey("showExtendedMetaData")) {
    UserPreferences().showExtendedMetaData =
        preferences.getBool("showExtendedMetaData")!;
  } else {
    UserPreferences().showExtendedMetaData = false;
  }
  if (preferences.containsKey("warningFontSize")) {
    UserPreferences().warningFontSize = preferences.getDouble("warningFontSize")!;
  } else {
    saveSettings(); //@todo remove?
    loadSettings();
  }
  if (preferences.containsKey("showWelcomeScreen")) {
    UserPreferences().showWelcomeScreen =
        preferences.getBool("showWelcomeScreen")!;
  }
  if (preferences.containsKey("sortWarningsBy")) {
    String temp = preferences.getString("sortWarningsBy")!;
    UserPreferences().sortWarningsBy = temp;
  }
  if (preferences.containsKey("showStatusNotification")) {
    UserPreferences().showStatusNotification =
        preferences.getBool("showStatusNotification")!;
  }
  if (preferences.containsKey("updateAvailable")) {
    UserPreferences().updateAvailable = preferences.getBool("updateAvailable")!;
  }

  if (preferences.containsKey("frequencyOfAPICall")) {
    UserPreferences().frequencyOfAPICall =
        preferences.getDouble("frequencyOfAPICall")!;
  }
  if (preferences.containsKey("selectedThemeMode")) {
    String temp = preferences.getString("selectedThemeMode")!;
    switch (temp) {
      case 'ThemeMode.system':
        UserPreferences().selectedThemeMode = ThemeMode.system;
        break;
      case 'ThemeMode.dark':
        UserPreferences().selectedThemeMode = ThemeMode.dark;
        break;
      case 'ThemeMode.light':
        UserPreferences().selectedThemeMode = ThemeMode.light;
        break;
    }
  } else {
    // Default value
    UserPreferences().selectedThemeMode = ThemeMode.system;
  }
  if (preferences.containsKey("selectedLightTheme")) {
    int temp = preferences.getInt("selectedLightTheme")!;
    if (temp > UserPreferences().availableLightThemes.length - 1 || temp == -1) {
      UserPreferences().selectedLightTheme =
          UserPreferences().availableLightThemes[0];
    } else {
      UserPreferences().selectedLightTheme =
          UserPreferences().availableLightThemes[temp];
    }
  }
  if (preferences.containsKey("selectedDarkTheme")) {
    int temp = preferences.getInt("selectedDarkTheme")!;
    if (temp > UserPreferences().availableDarkThemes.length - 1 || temp == -1) {
      UserPreferences().selectedDarkTheme =
          UserPreferences().availableDarkThemes[0];
    } else {
      UserPreferences().selectedDarkTheme =
          UserPreferences().availableDarkThemes[temp];
    }
  }

  if (preferences.containsKey("showAllWarnings")) {
    UserPreferences().showAllWarnings = preferences.getBool("showAllWarnings")!;
  }

  if (preferences.containsKey("activateAlertSwiss")) {
    UserPreferences().activateAlertSwiss =
        preferences.getBool("activateAlertSwiss")!;
  }
}
