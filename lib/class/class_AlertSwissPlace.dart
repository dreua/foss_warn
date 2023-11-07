import 'dart:convert';

import '../main.dart';
import 'abstract_Place.dart';
import 'class_WarnMessage.dart';

class AlertSwissPlace extends Place {
  final String _shortName;

  String get shortName => _shortName;

  AlertSwissPlace({required String shortName, required String name, String eTag = ""})
      : _shortName = shortName, super(name: name, warnings: [], eTag: eTag);

  AlertSwissPlace.withWarnings(
      {required String shortName,
      required String name,
      required List<WarnMessage> warnings,
      required eTag
      })
      : _shortName = shortName, super(name: name, warnings: warnings, eTag: eTag);

  factory AlertSwissPlace.fromJson(Map<String, dynamic> json) {

    /// create new warnMessage objects from saved data
    List<WarnMessage> createWarningList(String data) {
      List<dynamic> _jsonData = jsonDecode(data);
      List<WarnMessage> result = [];
      for (int i = 0; i < _jsonData.length; i++) {
        result.add(WarnMessage.fromJson(_jsonData[i]));
      }
      return result;
    }

    return AlertSwissPlace.withWarnings(
        name: json['name'] as String,
        shortName: json['shortName'] as String,
        warnings: createWarningList(json['warnings']),
        eTag: ""
    );
  }

  @override
  Map<String, dynamic> toJson() =>
      {'name': name, 'shortName': shortName, 'warnings': jsonEncode(warnings), 'eTag': eTag};


  @override
  Future<(String, bool)> callAPIAndGetWarnings() async {
    String _error = "";
    bool _successfullyFetched = true;
    if (!userPreferences.activateAlertSwiss) {
      _successfullyFetched = false;
      _error += "Sie haben einen AlertSwiss Ort hinzugefügt,"
          " aber AlertSwiss nicht als Quelle aktiviert \n";
    }
    // we don't call the API here because we just can get the warnings as bundle
   return (_error, _successfullyFetched);
  }
}
