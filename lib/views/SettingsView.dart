import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foss_warn/class/class_NotificationService.dart';
import 'package:foss_warn/class/class_alarmManager.dart';
import 'package:foss_warn/services/updateProvider.dart';
import 'package:foss_warn/views/DevSettingsView.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../class/class_userPreferences.dart';
import '../main.dart';
import '../services/apiHandler.dart';
import '../widgets/dialogs/ChooseThemeDialog.dart';
import 'NotificationSettingsView.dart';
import 'WelcomeView.dart';

import '../services/saveAndLoadSharedPreferences.dart';

import '../widgets/dialogs/FontSizeDialog.dart';
import '../widgets/dialogs/SortByDialog.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController frequencyController = new TextEditingController();
  final double _maxValueFrequencyOfAPICall = 999;
  final _platform = const MethodChannel("flutter.native/helper");

  @override
  void initState() {
    frequencyController.text =
        UserPreferences().frequencyOfAPICall.toInt().toString();

    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double indentOfCategoriesTitles = 15;

    final Map<int, String> startViewLabels = {
      0: AppLocalizations.of(context)!.settings_start_view_all_warnings,
      1: AppLocalizations.of(context)!.settings_start_view_only_my_places,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: indentOfCategoriesTitles,
                  top: indentOfCategoriesTitles),
              child: Text(
                AppLocalizations.of(context)!.settings_notification,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!
                  .settings_android_notification_settings),
              onTap: () => _openNotificationSettings(),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!
                  .settings_app_notification_settings),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationSettingsView()),
                );
              },
            ),
            ListTile(
                title: Text(AppLocalizations.of(context)!
                    .settings_show_status_notification_title),
                subtitle: Text(AppLocalizations.of(context)!
                    .settings_show_status_notification_subtitle),
                trailing: Switch(
                    value: UserPreferences().showStatusNotification,
                    onChanged: (value) {
                      setState(() {
                        UserPreferences().showStatusNotification = value;
                      });
                      saveSettings();
                      if (UserPreferences().showStatusNotification == false) {
                        NotificationService.cancelOneNotification(1);
                      }
                    })),
            ListTile(
              title: Text(
                  AppLocalizations.of(context)!.settings_background_service),
              trailing: Switch(
                  value: UserPreferences().shouldNotifyGeneral,
                  //@todo maybe we should add a confirmation dialog to prevent accidentally disabled background updates
                  onChanged: (value) {
                    setState(() {
                      UserPreferences().shouldNotifyGeneral = value;
                    });
                    saveSettings();
                    if (UserPreferences().shouldNotifyGeneral) {
                      AlarmManager().cancelBackgroundTask();
                      AlarmManager().registerBackgroundTask();
                    } else {
                      AlarmManager().cancelBackgroundTask();
                      print("background notification disabled");
                    }
                  }),
            ),
            UserPreferences().shouldNotifyGeneral ?
            ListTile(
              title: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!
                            .settings_frequent_of_background_update),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 70,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: frequencyController,
                                onChanged: (value) {
                                  if (value != "") {
                                    if (double.parse(value) > 0 &&
                                        double.parse(value) <=
                                            _maxValueFrequencyOfAPICall) {
                                      setState(() {
                                        UserPreferences().frequencyOfAPICall =
                                            double.parse(value);
                                      });
                                    } else {
                                      frequencyController.text = UserPreferences()
                                          .frequencyOfAPICall
                                          .round()
                                          .toString();
                                    }
                                  }
                                },
                                onTapOutside: (e) {
                                  // Check whether the text field is in focus,
                                  // because this method is executed every time
                                  // you tap somewhere in the settings, even
                                  // if the text field is not in focus at all
                                  if (FocusScope.of(context).isFirstFocus) {
                                    FocusScope.of(context).unfocus();
                                    saveSettings();
                                    AlarmManager().cancelBackgroundTask();
                                    AlarmManager().registerBackgroundTask();
                                    callAPI(); // call api and update notification
                                  }
                                },
                                onEditingComplete: () {
                                  FocusScope.of(context).unfocus();
                                  saveSettings();
                                  AlarmManager().cancelBackgroundTask();
                                  AlarmManager().registerBackgroundTask();
                                  callAPI(); // call api and update notification
                                },
                                decoration: InputDecoration(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Text("min"),
                            Expanded(
                              child: Slider(
                                value: UserPreferences().frequencyOfAPICall,
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                                min: 1,
                                max: _maxValueFrequencyOfAPICall,
                                onChanged: (value) {
                                  setState(() {
                                    UserPreferences().frequencyOfAPICall =
                                        value.roundToDouble();
                                    frequencyController.text = UserPreferences()
                                        .frequencyOfAPICall
                                        .toInt()
                                        .toString();
                                  });
                                },
                                onChangeEnd: (value) {
                                  saveSettings();
                                  AlarmManager().cancelBackgroundTask();
                                  AlarmManager().registerBackgroundTask();
                                  callAPI(); // call api and update notification
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ) : SizedBox(),
            Divider(
              height: 50,
              indent: 15.0,
              endIndent: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: indentOfCategoriesTitles),
              child: Text(
                AppLocalizations.of(context)!.settings_display,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_start_view),
              trailing: DropdownButton<int>(
                value: UserPreferences().startScreen,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                underline: Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onChanged: (int? newValue) {
                  setState(() {
                    UserPreferences().startScreen = newValue!;
                  });
                  saveSettings();
                },
                items: [0, 1].map<DropdownMenuItem<int>>((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(startViewLabels[value]!),
                  );
                }).toList(),
              ),
            ),
            ListTile(
                title: Text(AppLocalizations.of(context)!
                    .settings_show_extended_metadata),
                trailing: Switch(
                    value: UserPreferences().showExtendedMetaData,
                    onChanged: (value) {
                      setState(() {
                        UserPreferences().showExtendedMetaData = value;
                      });
                      saveSettings();
                    })),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_color_schema),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ChooseThemeDialog();
                  },
                );
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!
                  .settings_display_all_warnings_title),
              subtitle: Text(AppLocalizations.of(context)!
                  .settings_display_all_warnings_subtitle),
              trailing: Switch(
                  value: UserPreferences().showAllWarnings,
                  onChanged: (value) {
                    setState(() {
                      UserPreferences().showAllWarnings = value;
                    });
                    saveSettings();
                    final updater = Provider.of<Update>(context, listen: false);
                    updater.updateView();
                  }),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_font_size),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FontSizeDialog();
                  },
                );
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_sorting),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SortByDialog();
                  },
                );
              },
            ),
            Divider(
              height: 50,
              indent: 15.0,
              endIndent: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: indentOfCategoriesTitles),
              child: Text(
                AppLocalizations.of(context)!.settings_extended_settings,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_alertSwiss),
              subtitle: Text(
                  (AppLocalizations.of(context)!.settings_alertSwiss_subtitle)),
              trailing: Switch(
                value: UserPreferences().activateAlertSwiss,
                onChanged: (value) {
                  setState(() {
                    UserPreferences().activateAlertSwiss = value;
                  });
                  saveSettings();
                },
              ),
            ),
            ListTile(
              title: Text(
                  (AppLocalizations.of(context)!.settings_show_welcome_dialog)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomeView(),
                  ),
                );
              },
            ),
            ListTile(
              title:
                  Text((AppLocalizations.of(context)!.settings_dev_settings)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DevSettings()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openNotificationSettings() async {
    try {
      await _platform.invokeMethod("openNotificationSettings");
    } on PlatformException catch (e) {
      print(e);
    }
  }
}
