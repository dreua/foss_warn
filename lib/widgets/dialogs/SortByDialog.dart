import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../class/class_userPreferences.dart';
import '../../main.dart';
import '../../services/saveAndLoadSharedPreferences.dart';

class SortByDialog extends StatefulWidget {
  const SortByDialog({Key? key}) : super(key: key);

  @override
  _SortByDialogState createState() => _SortByDialogState();
}

class _SortByDialogState extends State<SortByDialog> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context)!.sorting_headline),
      children: [
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.sorting_by_date,
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.date_range),
          ),
          selectedColor: Theme.of(context).colorScheme.primary,
          selected: UserPreferences().sortWarningsBy == "date" ? true : false,
          onTap: () {
            setState(() {
              UserPreferences().sortWarningsBy = "date";
            });
            saveSettings();
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.sorting_by_warning_level,
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.warning),
          ),
          selectedColor: Theme.of(context).colorScheme.primary,
          selected: UserPreferences().sortWarningsBy == "severity" ? true : false,
          onTap: () {
            setState(() {
              UserPreferences().sortWarningsBy = "severity";
            });
            saveSettings();
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.sorting_by_source,
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.source),
          ),
          selectedColor: Theme.of(context).colorScheme.primary,
          selected: UserPreferences().sortWarningsBy == "source" ? true : false,
          onTap: () {
            setState(() {
              UserPreferences().sortWarningsBy = "source";
            });
            saveSettings();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
