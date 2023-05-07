import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:unifiedpush/constants.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:http/http.dart' as http;

import 'package:foss_warn/main.dart';
import 'checkForMyPlacesWarnings.dart';

String fossWarnServer = "http://10.0.2.2:3000";

void onNewEndpoint(String _endpoint, String _instance) {
  print("new Entpoint:" + _endpoint);
  if (_instance != instance) {
    return;
  }
  registered = true;
  endpoint = _endpoint;
}

void onRegistrationFailed(String instance) {
  print("Registration failed");
}

void onUnregistered(String instance) {
  print("unregister");
  registered = false;
  // send unregister to server
  http.post(
    Uri.parse(fossWarnServer + "/remove"),
    body: jsonEncode(<String, String>{
      'distributor_url': endpoint,
      'reason': "removed in app"
    }),
  );
}

/// callback function to handle notification from unifiedPush
Future<bool> onMessage(Uint8List _message, String _instance) async {
  debugPrint("instance " + _instance);
  if (_instance != instance) {
    return false;
  }
  debugPrint("onNotification");
  var payload = utf8.decode(_message);
  debugPrint("message: $payload");
  if(payload.contains("[DEBUG]") || payload.contains("[HEARTBEAT]") ) {
    // system message or debug
  } else {
    checkForMyPlacesWarnings(true, true);
  }
  return true;
}

unregisterPush() {
  UnifiedPush.unregister(instance);
  removeRegistration("unregister push"); //@todo test
  registered = false;
}

/// register client with one geocode
registerForGeocode(BuildContext context, String geocode) async {
  if(!registered) {
    await UnifiedPush.removeNoDistributorDialogACK();
    await UnifiedPush.registerAppWithDialog(
        context, instance, [featureAndroidBytesMessage]);
  }

 if(endpoint == "") {
   print("entpoint is not yet set");
 } else {
   // send new geocodes to server
   Response resp = await http.post(
     Uri.parse(fossWarnServer + "/registration"),
     headers: {"Content-Type": "application/json"},
     body: jsonEncode({'distributor_url': endpoint, 'geocode': geocode}),
   );
   print("register for geocode: ${resp.statusCode} ");
 }
}

/// send more then one geocode to the server to add or remove
updateRegistration(List<String> newGeocode, List<String> removeGeocode) async {
  debugPrint("update Registration");
  if (registered) {
    // send new geocodes to server
    http.post(
      Uri.parse(fossWarnServer + "/update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'distributor_url': endpoint,
        'new_geocode': newGeocode,
        'remove_geocode': removeGeocode
      }),
    );
  } else {
    print("client not registered..");
  }
}

/// send delete request to server
/// removes all entries from the database with that endpoint
removeRegistration(String reason) {
  if (registered) {
    // send new geocodes to server
    http.post(
      Uri.parse(fossWarnServer + "/remove"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'distributor_url': endpoint,
        'reason': reason,
      }),
    );
  } else {
    print("client not registered..");
  }
}

Future<http.Response> sendHttpRequest(String route, String body) {
  return http.post(
    Uri.parse(fossWarnServer + route),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: body,
  );
}
