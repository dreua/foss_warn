import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:http/http.dart' as http;

import 'package:foss_warn/main.dart';

String fossWarnServer = "http://localhost:3000";

void onNewEndpoint(String _endpoint, String _instance) {
  print("new Entpoint..:" + _endpoint);
  if (_instance != instance) {
    return;
  }
  registered = true;
  endpoint = _endpoint;
  print("Endpoint: " + endpoint);
}

void onRegistrationFailed(String instance) {
  print("Registration failed");
}

void onUnregistered(String instance) {
  print("unregister");
  registered = false;
}

void onMessage2(Uint8List message, String instance) {
  print("on Message");
  print(message);
}

Map<String, String> decodeMessageContentsUri(String message) {
  List<String> uri = Uri.decodeComponent(message).split("&");
  Map<String, String> decoded = {};
  for (var i in uri) {
    try {
      decoded[i.split("=")[0]] = i.split("=")[1];
    } on Exception {
      debugPrint("Couldn't decode " + i);
    }
  }
  return decoded;
}

Future<bool> onMessage(Uint8List _message, String _instance) async {
  debugPrint("instance " + _instance);
  if (_instance != instance) {
    return false;
  }
  debugPrint("onNotification");
  var payload = utf8.decode(_message);
  Map<String, String> message = decodeMessageContentsUri(payload);
  String title = message['title'] ?? "UP-Example";
  String body = message['message'] ?? "Could not get the content";
  debugPrint(title);
  return true;
}

unregisterPush() {
  UnifiedPush.unregister(instance);
}

registerForGeocode(BuildContext context, String geocode) async {
  print("Endpoint is: $endpoint");
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
