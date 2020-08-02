import 'dart:async';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) => _MyHomePageState();
}

class _MyHomePageState extends StatelessWidget {
  final ValueNotifier<bool> isSwitched = ValueNotifier<bool>(true);

  _MyHomePageState({bool isSwitched});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Align(
              alignment: Alignment.centerRight,
              child: Material(
                child: SensorToggle(),
              )),
          mainPage(),
        ],
      ),
    );
  }

  Widget getCardView(Color color) {
    return Card(
      elevation: 2.0,
      color: color,
      child: InkWell(
        highlightColor: Colors.white.withAlpha(30),
        splashColor: Colors.white.withAlpha(20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Center(
                child: Text("test"),
              )
            ]),
        onTap: () {},
      ),
    );
  }

  mainPage() {
    return GridView.count(
      primary: false,
      padding: const EdgeInsets.all(1.5),
      crossAxisCount: 2,
      childAspectRatio: 0.80,
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
      children: [
        getCardView(Colors.pink[50]),
        getCardView(Colors.blue[50]),
        getCardView(Colors.greenAccent[50]),
        getCardView(Colors.red[50]),
      ],
      shrinkWrap: true,
    );
  }
}

class SensorToggle extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SensorToggleImpl();
}

class SensorToggleImpl extends State<SensorToggle> {
  bool isSwitched = false;
  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  @override
  void initState() {
    super.initState();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });

      if (alertValidation()) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: Text('UserAccelerometer: 넘어질뻔?'),
              content: Text("Alert Dialog body"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    }));
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          color: Colors.white,
          child: Switch(
            value: this.isSwitched,
            onChanged: (value) {
              setState(() {
                isSwitched = value;
              });
            },
            activeTrackColor: Colors.lightGreenAccent,
            activeColor: Colors.green,
          ),
        )
      ],
    );
  }

  bool alertValidation() {
    List<bool> AccelerBool = <bool>[
      _userAccelerometerValues[0] >= 1,
      _userAccelerometerValues[1] >= 1,
      _userAccelerometerValues[2] >= 1,
//      _gyroscopeValues[0] >= 1,
//      _gyroscopeValues[1] >= 1,
//      _gyroscopeValues[2] >= 1
    ];
    print(AccelerBool.where((f)=>!f).toList());
    if (isSwitched && AccelerBool.where((f)=>!f).toList().isEmpty) {
      return true;
    }
    return false;
  }
}
