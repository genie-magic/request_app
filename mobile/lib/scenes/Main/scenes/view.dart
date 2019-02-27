import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:request_app/common/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewScene extends StatelessWidget {
  ViewScene (this.tabController);

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, User>(
        distinct: true,
        converter: (store) => store.state.userState.user,
        builder:(_, user) => ViewSceneContent(user, tabController)
    );
  }
}

class ViewSceneContent extends StatefulWidget {
  ViewSceneContent(this.signedInUser, this.tabController);
  final User signedInUser;
  final TabController tabController;

  @override
  ViewSceneContentState createState() => new ViewSceneContentState();
}

class ViewSceneContentState extends State<ViewSceneContent> with SingleTickerProviderStateMixin {

  bool isLoadingBeneficiary = false;
  List<Beneficiary>_beneficiaryList;

  /////////////////////////// Functional functions ////////////////////
  Future<void> _updateRecord() async {

  }

  Future<List<Beneficiary>> getBeneficiaries() async {
    setState(() {
      isLoadingBeneficiary = true;
    });

    QuerySnapshot querySnapshot = await firestore.collection('beneficiaries').getDocuments();
    setState(() {
      _beneficiaryList = querySnapshot.documents.map((DocumentSnapshot docSnapshot) {
        Beneficiary _benefit = new Beneficiary();
        _benefit.id = docSnapshot.documentID;
        _benefit.value = docSnapshot.data['value'];
        return _benefit;
      }).toList();

      isLoadingBeneficiary = false;
    });

    return _beneficiaryList;
  }

  Future<void> _deleteRecord(String id) async {
    firestore.collection('records').document(id).delete().then((result){
      _showSnackBar('Item deleted successfully!');
    }).catchError((error) {
      print('Error: $error');
      _showSnackBar(error);
    });
  }

  //////////////////////// Widget Functions /////////////////
  _showSnackBar(String text) {
    final SnackBar snackBar = SnackBar(content: Text(text));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  _showDeleteConfirmDialog(String id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Delete"),
            content: new Text("Are you sure you want to delete this item?"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              FlatButton(
                child: new Text("Cancel", style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: new Text("Delete", style: TextStyle(color: Colors.white)),
                color: Colors.red,
                onPressed: () {
                  _deleteRecord(id);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  Widget recordItem(Record record, String documentId) {
    if (_beneficiaryList == null) {
      return Text('Something went wrong...');
    }

    Beneficiary benefit = _beneficiaryList.firstWhere((element) {
      return element.id == record.beneficiaryId;
    });
    if (benefit == null) {
      return Text('Something went wrong...');
    }

    return Slidable(
      delegate: new SlidableDrawerDelegate(),
      actionExtentRatio: 0.25,
      child: Container(
        height: 80.0,
        color: Colors.white,
        child: ListTile(
          isThreeLine: true,
          leading: Image.network(
            record.photos[0],
            fit: BoxFit.cover,
            width: 60.0,
            height: 60.0,
          ),
          title: Text(record.title ?? ''),
          subtitle: Text('${record.currency} ${record.amount} ${record.city} ${record.zip} ${benefit.value}'),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Edit',
          color: Colors.blue,
          icon: Icons.edit,
          onTap: () {
            // GlobalValues.bAddOrEdit = false;
            // GlobalValues.recordId = documentId;
            // GlobalValues.record = record;
            setState(() {
              widget.tabController.index = 1; // Moves to request tab

              final store = StoreProvider.of<AppState>(context);
              store.dispatch(EditModeAction(
                record,
                documentId,
              ));
            });
          },
        ),
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            _showDeleteConfirmDialog(documentId);
          },
        )
      ],
    );
  }

  renderListView() {
    if (widget.signedInUser != null) {
      return StreamBuilder(
          stream: firestore.collection('records').where("userId", isEqualTo: widget.signedInUser.uuid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData || isLoadingBeneficiary) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return Text('Loading records failed!');


            if (snapshot.hasData) {

              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = snapshot.data.documents[index];
                  Record record = new Record.fromJson(document.data);
                  return Card(
                    child: recordItem(record, document.documentID),
                  );
                },
              );
            }
          }
      );
    } else {
      // final snackBar = SnackBar(content: Text('Signin is required'));
      // Scaffold.of(context).showSnackBar(snackBar);
      return Text('Signin is required');
    }
  }
  @override
  void initState() {
    super.initState();
    getBeneficiaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          margin: EdgeInsets.only(left: 20.0, top: 40.0, right: 20.0),
          child: renderListView()
        ),
      ),
    );
  }
}