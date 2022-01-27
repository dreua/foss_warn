import 'package:flutter/material.dart';

class CategoryExplanation extends StatefulWidget {
  const CategoryExplanation({Key? key}) : super(key: key);

  @override
  _CategoryExplanationState createState() => _CategoryExplanationState();
}

class _CategoryExplanationState extends State<CategoryExplanation> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Legende '),
      content: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: const <TextSpan>[
                  TextSpan(
                    text: "Mehr Informationen werden folgen... \n \n"
                  ),
                  TextSpan(
                      text: 'Gesundheit: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' Informationen bei bspw. Pandemien \n\n'),
                  TextSpan(
                      text: 'Feuer: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Informationen bei Bränden \n \n'),
                  TextSpan(
                      text: 'Infrastruktur: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Informationen bei ?  \n\n'),
                  TextSpan(
                      text: 'CBRNE: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text:
                          'Informationen bei Ereignissen mit chemischen,'
                              ' biologischen, radiologischen, nuklearen'
                          'und explosionsgefährdeten Stoffen \n\n'),
                  TextSpan(
                      text: 'Sicherheit: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: 'Informationen bei ? \n\n'),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('schließen',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        ),
      ],
    );
  }
}