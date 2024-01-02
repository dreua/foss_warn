import 'package:flutter/material.dart';
import 'package:foss_warn/enums/DataFetchStatus.dart';
import '../class/class_userPreferences.dart';
import '../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConnectionError extends StatelessWidget {
  const ConnectionError({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (UserPreferences().showAllWarnings && appState.dataFetchStatusOldAPI == DataFetchStatus.error) {
      return Container(
        padding: EdgeInsets.only(left: 10, bottom: 6, top: 6),
        //margin: EdgeInsets.only(bottom: 10),
        color: Colors.red,
        child: Row(
          children: [
            Icon(
              Icons.info,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              AppLocalizations.of(context)!.connection_error_no_internet,
              style: Theme.of(context).textTheme.displaySmall,
            )
          ],
        ),
      );
    } else if (UserPreferences().areWarningsFromCache) {
      return Container(
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 6, top: 6),
        //margin: EdgeInsets.only(bottom: 10),
        color: Colors.orange,
        child: Row(
          children: [
            Icon(
              Icons.info,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  AppLocalizations.of(context)!.connection_error_no_internet,
                  style: Theme.of(context).textTheme.displaySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      );
    } else {
      return SizedBox();
    }
  }
}
