import 'package:flutter/material.dart';
import '../lib/flutter_location_picker.dart';

void main ()=> runApp(MaterialApp(
  home: Scaffold(
    body: App(),
  ),
));

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: RaisedButton(
          child: Center(
            child: Text(
              'Click me!',
              style: TextStyle(
                fontSize: 24.0
              ),
            ),
          ),
          onPressed: () {
            LocationPicker.showPicker(
              context,
              showTitleActions: true,
              initialProvince: '上海',
              initialCity: '上海',
              initialTown: null,
              onChanged: (p, c, t) {
                print('$p $c $t');
              },
              onConfirm: (p, c, t) {
                print('$p $c $t');
              },
            );
          }
        ),
      ),
    );
  }
}