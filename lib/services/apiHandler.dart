import 'dart:convert';
import 'package:foss_warn/class/class_AlertSwissPlace.dart';
import '../class/class_NinaPlace.dart';
import '../class/class_WarnMessage.dart';
import '../class/class_Area.dart';
import '../class/class_Geocode.dart';
import '../class/abstract_Place.dart';
import 'alertSwiss.dart';
import 'listHandler.dart';
import '../views/SettingsView.dart';
import 'sendStatusNotification.dart';
import 'saveAndLoadSharedPreferences.dart';

import 'package:http/http.dart';

/// call the nina api and load for myPlaces the warnings
Future callAPI() async {
  bool successfullyFetched = true;
  String error = "";
  List<WarnMessage> tempWarnMessageList = [];
  tempWarnMessageList.clear();
  print("call API");
  String baseUrl = "https://warnung.bund.de/api31";
  // String geocode = "071110000000"; // just for testing

  await loadSettings();
  await loadMyPlacesList();

  for (Place p in myPlaceList) {
    // if the place is for swiss skip this place
    print(p.name);
    if (p is AlertSwissPlace) {
      if (!activateAlertSwiss) {
        successfullyFetched = false;
        error += "Sie haben einen AlertSwiss Ort hinzugefügt,"
            " aber AlertSwiss nicht als Quelle aktiviert \n";
      }
      continue;
    }
    // it is a nina place
    else if (p is NinaPlace) {
      try {
        Response response; //response var for get request
        var data; //var for response data
        // the warnings are only on kreisebene wo we only care about the first 5
        // letters from the code and fill the rest with 0s
        print(p.geocode.geocodeNumber);
        String geocode = p.geocode.geocodeNumber.substring(0, 5) + "0000000";

        await loadSettings();
        await loadEtags();

        print("call: " + baseUrl + "/dashboard/" + geocode + ".json");
        // get overview if warnings exits for myplaces
        response =
            await get(Uri.parse(baseUrl + "/dashboard/" + geocode + ".json"));

        // check if request was successfully
        if (response.statusCode == 200) {
          data = jsonDecode(utf8.decode(response.bodyBytes));
          tempWarnMessageList.clear();

          for (int i = 0; i < data.length; i++) {
            String id = data[i]["payload"]["id"];
            String provider = data[i]["payload"]["data"]["provider"];
            print("provider: " + provider);
            var responseDetails =
                await get(Uri.parse(baseUrl + "/warnings/" + id + ".json"));
            // check if request was successfully
            if (responseDetails.statusCode == 200) {
              var warningDetails =
                  jsonDecode(utf8.decode(responseDetails.bodyBytes));
              WarnMessage? temp = createWarning(warningDetails, provider,
                  p.name, p.geocode);
              if (temp != null) {

                tempWarnMessageList.add(temp);
                if(!p.warnings.any((element) => element.identifier == temp.identifier)) {
                  print("add warning to p: " + temp.headline + " " + temp.notified.toString());
                  p.warnings.add(temp);
                  p.countWarnings++;
                }

                // }  //@todo: fix displaying warnings twice
              }
            } else {
              print("[callAPI] Error: tried calling: " +
                  baseUrl +
                  "/warnings/" +
                  id +
                  ".json");
            }
          }
          // remove old warnings
          List<WarnMessage> WarnMessageToRemove = [];
          for(WarnMessage message in p.warnings) {
            if(!tempWarnMessageList.any((element) => element.identifier == message.identifier)) {
              WarnMessageToRemove.add(message);
            }
          }
          for(WarnMessage message in WarnMessageToRemove) {
            p.warnings.remove(message);
            p.countWarnings--;
          }

          areWarningsFromCache = false;
          print("Save my places list with new warnings");
          saveMyPlacesList();

        } else {
          print("could not reach: ");
          successfullyFetched = false;
          error += "We have a problem to reach the warnings for:  ${p.name}"
              " (Statuscode:  ${response.statusCode} ) \n";
        }
      } catch (e) {
        print("Something went wrong while trying to call the NINA API:  ${e}");
        successfullyFetched = false;
        areWarningsFromCache = true;
        error += e.toString() + " \n";
      }
    }
  }
  if (showStatusNotification) {
    if (error != "") {
      sendStatusUpdateNotification(successfullyFetched, error);
    } else {
      sendStatusUpdateNotification(successfullyFetched);
    }
  }

  // warnMessageList.clear(); //clear List
  // warnMessageList = tempWarnMessageList; // transfer temp List in real list

  // call alert Swiss
  if (activateAlertSwiss) {
    await callAlertSwissAPI();
  }

  //@todo fix
  /* if (warnMessageList.isNotEmpty) {
    cacheWarnings();
  } else if (!successfullyFetched) {
    loadCachedWarnings();
  } else {
    // there are no warnings and no stored
    // warning, so we we have nothing to display
    areWarningsFromCache = false;
  } */

  print("finished calling API");
  return "";
}

/// generate WarnMessage object
WarnMessage? createWarning(var data, String provider, String placeName,
    Geocode geocode) {
  /// generate empty list as placeholder
  /// @todo fill with real data
  List<Area> generateAreaList(int i) {
    List<Area> tempAreaList = [];
    tempAreaList.add(
      Area(areaDesc: placeName, geocodeList: [
        geocode,
      ]),
    );
    return tempAreaList;
  }

  String findPublisher(var parameter) {
    for (int i = 0; i < parameter.length; i++) {
      if (parameter[i]["valueName"] == "sender_langname") {
        return parameter[i]["value"];
      }
    }
    return "Deutscher Wetterdienst";
  }

  try {
    return WarnMessage.fromJsonTemp(data, provider,
        findPublisher(data["info"][0]["parameter"]), generateAreaList(1));
  } catch (e) {
    print("Error parsing warning: ${data["identifier"]} -> ${e.toString()}");
  }
  return null;
}
