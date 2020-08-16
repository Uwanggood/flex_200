import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

import 'httpExample.dart';

void main() => runApp(Test());

class Test extends StatelessWidget {
  TabHome tabHome = new TabHome();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'test',
      home: tabHome.mainTab(),
    );
  }
}

class TabHome {
  mainTab() {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cake),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cake),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cake),
          )
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text('Page 1 of tab $index'),
              ),
              child: Center(
                child: CupertinoButton(
                  child: InnerTabPage(index: index),
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(
                        builder: (BuildContext context) {
                          return CupertinoPageScaffold(
                            navigationBar: CupertinoNavigationBar(
                              middle: Text('Page 2 of tab $index'),
                            ),
                            child: Center(
                              child: CupertinoButton(
                                child: const Text('Back'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class InnerTabPage extends StatefulWidget {
  final int index;

  InnerTabPage({Key key, this.index}) : super(key: key);

  @override
  _InnerTabPageState createState() => _InnerTabPageState();
}

class _InnerTabPageState extends State<InnerTabPage> {
  Future<List> post;
  List colors = [Colors.red, Colors.green, Colors.yellow];
  @override
  void initState() {
    super.initState();
    post = fetchPost('greeting');
  }

  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    switch (widget.index) {
      case 0:
        return FutureBuilder<List>(
          future: post,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final item = snapshot.data[0];
              return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: item.length,
                  itemBuilder: (BuildContext context, int index) {
                    return LimitedBox(
                        maxHeight: 80,
                        child: Container(
                            height: 80,
                            color: colors[new Random().nextInt(3)],
                            child: Column(
                              children: [
                                Text(item['title'].toString()),
                              ],
                            )
                        ),
                    );
                  }
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // 기본적으로 로딩 Spinner를 보여줍니다.
            return CircularProgressIndicator();
          },
        );
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
      default:
        break;
    }
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
    print(AccelerBool.where((f) => !f).toList());
    if (isSwitched && AccelerBool
        .where((f) => !f)
        .toList()
        .isEmpty) {
      return true;
    }
    return false;
  }
}
