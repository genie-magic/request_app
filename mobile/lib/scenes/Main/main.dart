import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:request_app/common/globals.dart';

// Import scenes
import 'package:request_app/scenes/Main/scenes/help.dart';
import 'package:request_app/scenes/Main/scenes/home.dart';
import 'package:request_app/scenes/Main/scenes/request.dart';
import 'package:request_app/scenes/Main/scenes/view.dart';

class MainScene extends StatefulWidget {
  static const String routeName = "/main_scene";

  @override
  MainSceneState createState() => new MainSceneState();
}

class MainSceneState extends State<MainScene>
    with SingleTickerProviderStateMixin {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TabController _tabController;

  _loginClicked() {
    _handleSignIn()
        .then((FirebaseUser user) => (user) {
              GlobalValues.user = user;
            })
        .catchError((e) => print(e));
  }

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);

    User userModel = new User();
    userModel.userName = user.displayName;
    userModel.uuid = user.uid;
    final store = StoreProvider.of<AppState>(context);
    store.dispatch(LoginAction(userModel));

    return user;
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Request app"),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: <Tab>[
              Tab(icon: Icon(FontAwesomeIcons.search)),
              Tab(icon: Icon(FontAwesomeIcons.dollarSign)),
              Tab(icon: Icon(FontAwesomeIcons.home)),
              Tab(icon: Icon(FontAwesomeIcons.solidQuestionCircle))
            ],
          ),
          actions: <Widget>[
            IconButton(
              onPressed: _loginClicked,
              icon: Icon(FontAwesomeIcons.userCircle),
            )
          ],
        ),
        body: Container(
          child: TabBarView(controller: _tabController, children: <Widget>[
            HomeScene(),
            RequestScene(_handleSignIn),
            ViewScene(),
            HelpScene(),
          ]),
        ));
  }
}
