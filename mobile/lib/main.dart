import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:request_app/common/globals.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:key_value_store_flutter/key_value_store_flutter.dart';
import 'package:http/http.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

// Import scenes
import 'package:request_app/scenes/main/main.dart';
import 'package:request_app/scenes/Login/login.dart';

Future<void> main() async {
  globalFirebaseApp = await FirebaseApp.configure(
    name: 'requestapp',
    options: Platform.isIOS
        ? const FirebaseOptions(
      googleAppID: '1:297855924061:ios:c6de2b69b03a5be8',
      gcmSenderID: '297855924061',
      databaseURL: 'https://request-app-67d83.firebaseio.com',
    )
        : const FirebaseOptions(
      googleAppID: '1:6448250849:android:5791daf22a4b0377',
      apiKey: 'AIzaSyA3rScbfJfKwWgBZkBSP44eLVJphaLxpBM',
      databaseURL: 'https://request-app-67d83.firebaseio.com',
      projectID: 'request-app-67d83',
    ),
  );
  firestore = Firestore(app: globalFirebaseApp);
  await firestore.settings(timestampsInSnapshotsEnabled: true);

  firebaseStorage = FirebaseStorage(
      app: globalFirebaseApp, storageBucket: 'gs://request-app-67d83.appspot.com');

  final prefs = await SharedPreferences.getInstance();
  final keyValueStore = FlutterKeyValueStore(prefs);
  final store = createStore(Client(), keyValueStore);

  runApp(RequestApp(store));
}

class RequestApp extends StatefulWidget {
  RequestApp(this.store);
  final Store<AppState> store;

  @override
  RequestAppState createState() => RequestAppState();
}

class RequestAppState extends State<RequestApp> {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.blue,
          ),
          home: MainScene(),
          routes: <String, WidgetBuilder> {
            MainScene.routeName: (BuildContext context) => MainScene(),
            LoginScene.routeName: (BuildContext context) => LoginScene()
          }
      )
    );
  }
}