import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// ignore: non_constant_identifier_names
final String TableName = 'Dog';
class Dog {
  final int id;
  final String name;

  Dog({this.id, this.name});
}
initDB() async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, 'MyDogsDB.db');

  return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $TableName(
            id INTEGER PRIMARY KEY,
            name TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion){}
  );
}

class DBHelper {

  DBHelper._();
  static final DBHelper _db = DBHelper._();
  factory DBHelper() => _db;

  static Database _database;

  Future<Database> get database async {
    if(_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'MyDogsDB.db');

    return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE $TableName(
            id INTEGER PRIMARY KEY,
            name TEXT,
          )
        ''');
        },
        onUpgrade: (db, oldVersion, newVersion){}
    );
  }

  //Create
  createData(Dog dog) async {
    final db = await database;
    var res = await db.rawInsert('INSERT INTO $TableName(name) VALUES(?)', [dog.name]);
    return res;
  }

  //Read
  getDog(int id) async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM $TableName WHERE id = ?', [id]);
    return res.isNotEmpty ? Dog(id: res.first['id'], name: res.first['name']) : Null;
  }

  //Read All
  Future<List<Dog>> getAllDogs() async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM $TableName');
    List<Dog> list = res.isNotEmpty ? res.map((c) => Dog(id:c['id'], name:c['name'])).toList() : [];

    return list;
  }

  //Delete
  deleteDog(int id) async {
    final db = await database;
    var res = db.rawDelete('DELETE FROM $TableName WHERE id = ?', [id]);
    return res;
  }

  //Delete All
  deleteAllDogs() async {
    final db = await database;
    db.rawDelete('DELETE FROM $TableName');
  }

}


List<Dog> dogs = [
  Dog(name: '푸들이'),
  Dog(name: '삽살이'),
  Dog(name: '말티말티'),
  Dog(name: '강돌이'),
  Dog(name: '진져'),
  Dog(name: '백구'),
];

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Dog Database'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder(
          future: DBHelper().getAllDogs(),
          builder: (BuildContext context, AsyncSnapshot<List<Dog>> snapshot) {

            if(snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Dog item = snapshot.data[index];
                  return Dismissible(
                    key: UniqueKey(),
                    onDismissed: (direction) {
                      DBHelper().deleteDog(item.id);
                      setState(() {});
                    },
                    child: Center(child: Text(item.name)),
                  );
                },
              );
            }
            else
            {
              return Center(child: CircularProgressIndicator(),);
            }
          },
        ),

        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton(
              child: Icon(Icons.refresh),
              onPressed: () {
                DBHelper().deleteAllDogs();
                setState(() {});
              },
            ),
            SizedBox(height: 8.0),
            FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Dog dog = dogs[Random().nextInt(dogs.length)];
                DBHelper().createData(dog);
                setState(() {});
              },
            ),
          ],
        )

    );
  }
}