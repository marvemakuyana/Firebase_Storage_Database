import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'auth.dart' as fbAuth;
import 'storage.dart' as fbStorage;
import 'database.dart' as fbDatabase;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart'; // needed for base name

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'firebaseapp',
    options: new FirebaseOptions(
      googleAppID: '1:874313680436:android:de02fa3b682ae93497ec61',
      gcmSenderID: '874313680436',
      apiKey: 'AIzaSyCSOFr1FMQwqICIKrSy6JW4CnHjinkJO0g',
      projectID: 'fir-app-a189e',
      databaseURL: 'https://fir-app-a189e.firebaseio.com',
      )
  );

  final FirebaseStorage storage = new FirebaseStorage(app: app, storageBucket: 'gs://fir-app-a189e.appspot.com/');
  final FirebaseDatabase database = new FirebaseDatabase(app: app);


  runApp(new MaterialApp(
    home: new MyApp(app: app, database:database ,storage: storage),
  ));
}

class MyApp extends StatefulWidget {
  MyApp({this.app, this.database, this.storage});

  final FirebaseApp app;
  final FirebaseDatabase database;
  final FirebaseStorage storage;
  @override
  _State createState() => new _State(app: app, database:database ,storage: storage);
}

class _State extends State<MyApp> {

  _State({this.app, this.database, this.storage});

  final FirebaseApp app;
  final FirebaseDatabase database;
  final FirebaseStorage storage;

  String _status;
  String _location;
  StreamSubscription<Event> _counterSubscription;

  String _username;
  String _text;

  @override
  void initState() {
    super.initState();
    _status = 'Not Authenticated';
    _signIn();
  }

  void _signIn() async {
    if(await fbAuth.signInGoogle() == true) {

      _username = await fbAuth.username();
      setState(() {
        _status = 'Signed In';
      });
      _initDatabase();
    } else {
      setState(() {
        _status = 'Could not sign in!';
      });
    }
  }

  void _signOut() async {
    if(await fbAuth.signOut() == true) {
      setState(() {
        _status = 'Signed Out';
      });
    } else {
      setState(() {
        _status = 'Signed In';
      });
    }
  }

  void _upload() async {
     Directory systemTempDir = Directory.systemTemp;
     File file = await File('${systemTempDir.path}/foo.txt').create();
     await file.writeAsString('Hello World');

     String location = await fbStorage.upload(file, basename(file.path));
     setState(() {
       _location = location;
       _status = 'Uploaded';
     });

     print('Uploaded to $location');
  }

  void _download() async {

    if(_location.isEmpty) {
      setState(() {
        _status = 'Please upload first';
      });
      return;
    }
    Uri location = Uri.parse(_location);
    String data = await fbStorage.download(location);
    setState(() {
      _status = 'Downloaded: $data';
    });
  }
  void _initDatabase()  async{
     fbDatabase.init(database);

      _counterSubscription = fbDatabase.counterRef.onValue.listen((Event event) { 
        setState(() {
          fbDatabase.error = null;
          fbDatabase.counter = event.snapshot.value ?? 0;
        });
      }, onError: (Object o){
        final DatabaseError error = o;
        setState(() {
          fbDatabase.error = error;
        });
      }
      );
  }

  void _increment() async{
    int value = fbDatabase.counter + 1;
    fbDatabase.setCounter(value);
  }

  void _decrement()async {
     int value = fbDatabase.counter - 1;
      fbDatabase.setCounter(value);
  }

  void _addData() async {
    await fbDatabase.addData(_username);
    setState(() {
      _status = 'Data Added';
    });
  }

  void _removeData() async {
    await fbDatabase.removeData(_username);
    setState(() {
      _status = 'Data Removed';
    });
  }

  void _setData(String key, String value) async {
    await fbDatabase.setData(_username, key, value);
    setState(() {
      _status = 'Data Set';
    });
  }

  void _updateData(String key, String value) async {
    await fbDatabase.updateData(_username, key, value);
    setState(() {
      _status = 'Data Updated';
    });
  }

  void _findData(String key) async {
    String value = await fbDatabase.findData(_username, key);
    setState(() {
      _status = value;
    });
  }

  void _findRange(String key) async {
    String value = await fbDatabase.findRange(_username, key);
    setState(() {
      _status = value;
    });
  }

  void _onChanged(String value) {
    setState(() {
      _text = value;
    });
  }

  void _saveData() async {
    await fbDatabase.updateData(_username, 'message', _text);
    String data = await fbDatabase.findData(_username, 'message');

    setState(() {
      _status = data;
    });
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Name here'),
      ),
      body: new Container(
        padding: new EdgeInsets.all(32.0),
        child: new Center(
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text(_status),
              // new Text('Counter ${fbDatabase.counter}'),
              // new Text('Error: ${fbDatabase.error.toString()}'),
              new TextField(onChanged: _onChanged,),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   new RaisedButton(onPressed: _signOut, child: new Text('Sign Out'),),
                  new RaisedButton(onPressed: _signIn, child: new Text('Sign In Google'),),
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new RaisedButton(onPressed: _addData, child: new Text('Add Data'),),
                  new RaisedButton(onPressed: _removeData, child: new Text('Remove Data'),),
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new RaisedButton(onPressed: () => _setData('Key2', 'This is a set value'), child: new Text('Set Data'),),
                  new RaisedButton(onPressed: () => _updateData('Key2', 'This is an updated value'), child: new Text('Update Data'),),
                ],
              ),
              // new Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     new RaisedButton(onPressed: () => _findData('Key2'), child: new Text('Find Data'),),
              //     new RaisedButton(onPressed: () => _findRange('Key2'), child: new Text('Find Range'),),
              //   ],
              // ),
              new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    new RaisedButton(onPressed: _saveData, child: new Text('Save'),),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
