import 'package:flutter/material.dart';
import '../lib/flutter_location_picker.dart';

void main ()=> runApp(MaterialApp(
  home: Scaffold(
    body: App(),
  ),
));

class App extends StatefulWidget {
  @override
  _AppState createState ()=> _AppState();
}

class _AppState extends State<App> {
  String province = '上海';
  String city = '上海';
  var town = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Pick location',
                style: TextStyle(
                  fontSize: 24.0,
                  height: 2.0
                ),
              ),
              Text(
                '$province $city ${town ?? ''}',
                style: TextStyle(
                  fontSize: 22.0
                ),
              )
            ],
          ),
          onPressed: () {
            LocationPicker.showPicker(
              context,
              showTitleActions: true,
              initialProvince: province,
              initialCity: city,
              initialTown: town,
              onChanged: (p, c, t) {
                print('$p $c $t');
              },
              onConfirm: (p, c, t) {
                print('$p $c $t');
                setState((){
                  province = p;
                  city = c;
                  town = t;
                });
              },
            );
          }
        ),
      ),
    );
  }
}