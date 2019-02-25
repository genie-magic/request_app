import 'dart:io';
import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:validate/validate.dart';
import 'package:request_app/common/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
class RequestScene extends StatelessWidget {
  RequestScene(this.callLogin);

  final callLogin;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, User>(
      distinct: true,
      converter: (store) => store.state.userState.user,
      builder:(_, user) => RequestSceneContent(user, callLogin)
    );
  }
}

class RequestSceneContent extends StatefulWidget {
  RequestSceneContent(this.signedInUser, this.callLogin);
  final User signedInUser;
  final callLogin;

  @override
  RequestSceneContentState createState() => new RequestSceneContentState();
}

class RequestSceneContentState extends State<RequestSceneContent> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final _currenciesList = ["USD", "CAN", "GBP"];
  String _selectedCurrency;

  bool isLoadingBeneficiary = false;
  List<Beneficiary>_beneficiaryList;
  Beneficiary _beneficiary;

  List<String> imageUrls = [
    'https://firebasestorage.googleapis.com/v0/b/request-app-67d83.appspot.com/o/aladdin_jasmine_genie_96044_1280x720.jpg?alt=media&token=ad37480e-f26c-48fe-abed-d3fb811374ee',
    'https://firebasestorage.googleapis.com/v0/b/request-app-67d83.appspot.com/o/wp1960528.jpg?alt=media&token=0817cfdd-1a32-4c49-9d29-6c65e343fa03',
    'https://firebasestorage.googleapis.com/v0/b/request-app-67d83.appspot.com/o/wp1960529.jpg?alt=media&token=07e9b2bd-9bfe-452f-8030-b039a94dafcf',
    'https://firebasestorage.googleapis.com/v0/b/request-app-67d83.appspot.com/o/zermatt_4k_hd_wallpaper_valais_switzerland_travel_tourism_resort_mountain_snow_clouds_sky_24499-1024x576.jpg?alt=media&token=1b13c53b-e23d-4a75-beee-03cbf0b13842',
  ];

  CollectionReference get records => firestore.collection('records');
  Record _record = new Record();

  File _imageFile;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = _currenciesList[0];
    getBeneficiaries();
  }

  ///////////////// Functional functions ////////////////////////
  Future<void> _addRecord() async {
    await records.add(_record.toJson());
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

      if (_beneficiaryList.length > 0) {
        _beneficiary = _beneficiaryList[0];
      }

      isLoadingBeneficiary = false;
    });

    return _beneficiaryList;
  }
  ///////////////// Event handlers //////////////////////////////
  _onSubmit() {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();

      // If user signed in add record
      if (widget.signedInUser != null) {
        _record.userId = widget.signedInUser.uuid;
        _record.beneficiaryId = _beneficiary.id;
        print('amount here');
        print(_record.amount);
        print(_record);
        _addRecord();
      }
      // If user not signed in go to login modal
      else {
        widget?.callLogin();
      }
    }
  }

  _onClickImage(index) {
    setState(() {
      imageUrls.removeAt(index);
    });
  }

  Future _onAddImage(ImageSource source) async {

    // Can upload only up to 4 images
    if (imageUrls.length >= 4) {
      final snackBar = SnackBar(content: Text('Can upload only up to 4 images!'));
      Scaffold.of(context).showSnackBar(snackBar);
      return;
    }

    _imageFile = await ImagePicker.pickImage(source: source);

    // Upload to firebase storage
  }
  //////////////////////////// Widgets.... ////////////////////////////////
  List<Widget> renderImageUrls() {
    List<Widget> widgets = [];
    for (var i = 0; i < imageUrls.length; i++) {
      widgets.add(
        GestureDetector(
          onTap: () {
            _onClickImage(i);
          },
          child: Image.network(
            imageUrls[i],
            fit: BoxFit.cover,
            width: (MediaQuery.of(context).size.width - 40) / 4,
          ),
        )
      );
    }
    return widgets;
  }

  Widget currencyDropDown() {
    return DropdownButton<String>(
      value: _selectedCurrency,
      items: _currenciesList.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value)
        );
      }).toList(),
      onChanged: (String selectedCurrency) {
        setState(() {
          _selectedCurrency = selectedCurrency;
        });
      },
    );
  }

  Widget beneficiaryDropDown() {
    if (isLoadingBeneficiary) {
      return Center(child: CircularProgressIndicator());
    } else {
      return DropdownButton<Beneficiary>(
        value: _beneficiary,
        items: _beneficiaryList.map((Beneficiary value) {
          return DropdownMenuItem<Beneficiary>(
              value: value,
              child: Text(value.value)
          );
        }).toList(),
        onChanged: ((Beneficiary beneficiary) {
          setState(() {
            _beneficiary = beneficiary;
          });
        }),
      );
    }
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
          child: Form(
            key: _formKey,
            autovalidate: true,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                      hintText: "Requested amount",
                      labelText: "Amount"
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    try {
                      Validate.notBlank(value);
                    } catch (e) {
                      return "Amount can't be an empty value";
                    }

                    if(!GlobalFunctions.isNumeric(value)) {
                      return "Amount can be only digit!";
                    }

                    if (double.parse(value) < 0) {
                      return "Amount can be only positive value";
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _record.amount = double.parse(value);
                  },
                ),
                FormField(
                  builder: (FormFieldState state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Currency"
                      ),
                      isEmpty: _selectedCurrency == '',
                      child: DropdownButtonHideUnderline(child: currencyDropDown()),
                    );
                  },
                  onSaved: (value) {
                    _record.currency = _selectedCurrency;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: "Please input title here",
                    labelText: "Title"
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    try {
                      Validate.notBlank(value);
                    } catch (e) {
                      return "Title can't be an empty value";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _record.title = value;
                  },
                ),
                TextFormField(
                  maxLines: null,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    hintText: "Please input description here",
                    labelText: "Description"
                  ),
                  validator: (value) {
                    try {
                      Validate.notBlank(value);
                    } catch (e) {
                      return "Description can't be an empty value";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _record.description = value;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    hintText: "Please input city here",
                    labelText: "City"
                  ),
                  validator: (value) {
                    try {
                      Validate.notBlank(value);
                    } catch (e) {
                      return "City can't be an empty value";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _record.city = value;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Zipcode",
                    labelText: "Zip*"
                  ),
                  validator: (value) {
                    try {
                      Validate.notBlank(value);
                    } catch (e) {
                      return "Zip can't be an empty value";
                    }

                    if(!GlobalFunctions.isNumeric(value)) {
                      return "Zip can be only digit!";
                    }

                    if (value.length != 5) {
                      return "Not valid zip";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _record.zip = value;
                  },
                ),
                FormField(
                  builder: (FormFieldState state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Beneficiary*"
                      ),
                      isEmpty: _beneficiary == null,
                      child: DropdownButtonHideUnderline(child: beneficiaryDropDown()),
                    );
                  },
                  onSaved: (value) {
                    _record.beneficiaryId = value;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    hintText: "Link to Website",
                    labelText: "Link to Website"
                  ),
                  onSaved: (value) {
                    _record.link = value;
                  },
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: RaisedButton.icon(
                        onPressed: () {
                          _onAddImage(ImageSource.gallery);
                        },
                        icon: Icon(Icons.photo_library),
                        label: Text('Library image'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: RaisedButton.icon(
                        onPressed: () {
                          _onAddImage(ImageSource.camera);
                        },
                        icon: Icon(Icons.camera_alt),
                        label: Text('Camera image'),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: this.renderImageUrls(),
                )
              ],
            ),
          ),
        )
      ),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            FlatButton.icon(icon: Icon(FontAwesomeIcons.solidSave), onPressed: _onSubmit, label: Text("Submit")),
            FlatButton.icon(icon: Icon(FontAwesomeIcons.solidTimesCircle), onPressed: () {}, label: Text("Cancel")),
          ],
        ),
      ),
    );
  }
}