import 'dart:io';
import 'dart:async';
import 'package:core/core.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:validate/validate.dart';
import 'package:request_app/common/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class RequestScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('************************************request scne build is called************************************');
    return StoreConnector<AppState, RequestSceneModel>(
      distinct: true,
      converter: (store) {
        print('+++++++++++++++++++++++bAddOrEdit flag here+++++++++++++++++++++++');
        print(RequestSceneModel.fromStore(store).bAddOrEdit);
          return RequestSceneModel.fromStore(store);
        },
      builder:(_, requestSceneModel) => RequestSceneContent(requestSceneModel)
    );
  }
}

class RequestSceneContent extends StatefulWidget {
  RequestSceneContent(this._requestSceneModel)
      : signedInUser = _requestSceneModel.loginUser;
  RequestSceneModel _requestSceneModel;
  User signedInUser;

  @override
  RequestSceneContentState createState() {
    print('==============================================create state is called==============================================');
    return RequestSceneContentState();
  }
}

class RequestSceneContentState extends State<RequestSceneContent> with AutomaticKeepAliveClientMixin<RequestSceneContent> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final _currenciesList = ["USD", "CAN", "GBP"];
  String _selectedCurrency;

  bool isLoadingBeneficiary = false;
  List<Beneficiary>_beneficiaryList;
  Beneficiary _beneficiary;

  List<String> imageUrls = [];

  CollectionReference get records => firestore.collection('records');
  Record _record;

  File _imageFile;
  bool isUploadingImage= false;

  bool bAddOrEdit; // True : Add, False : Edit
  String editingRecordId; // In Edit mode only

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    _selectedCurrency = _currenciesList[0];
    getBeneficiaries();
    this._formKey.currentState?.reset();

    // After fetching global status values and reset global status values
    bAddOrEdit = widget._requestSceneModel.bAddOrEdit;

    // If 'add' mode
    if (bAddOrEdit == true) {
      _record = new Record();
    } else {
      _record = widget._requestSceneModel.record;
      editingRecordId = widget._requestSceneModel.editRecordID;
      imageUrls = _record.photos;
      _selectedCurrency = _record.currency;
    }

    super.initState();
  }

  ///////////////// Functional functions ////////////////////////
  Future<void> _addRecord() async {
    firestore.runTransaction((Transaction txt) async {
      var _result = await records.add(_record.toJson()).then((value) {
        _showSnackBar('Record added successfully');
      }).catchError((error) {
        _showSnackBar(error);
      });
    });
  }

  Future<void> _updateRecord() async {
    DocumentReference documentReference =
      firestore.collection('records').document(editingRecordId);
      firestore.runTransaction((Transaction tx) async {
        DocumentSnapshot documentSnapshot = await tx.get(documentReference);

        if (documentSnapshot.exists) {
          await tx.update(documentReference, _record.toJson()).then((value) {
            _showSnackBar('Record updated successfully');
          }).catchError((error) {
            _showSnackBar(error);
          });
        }
    });
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
        // If 'add' mode
        if (bAddOrEdit == true) {
          _beneficiary = _beneficiaryList[0];
        }
        // if 'edit' mode
        else {
          _beneficiary = _beneficiaryList.firstWhere((element) => element.id == _record.beneficiaryId, orElse: () => _beneficiaryList[0]);
        }

      }

      isLoadingBeneficiary = false;
    });

    return _beneficiaryList;
  }

  _showSnackBar(String text) {
    final SnackBar snackBar = SnackBar(content: Text(text));
    Scaffold.of(context).showSnackBar(snackBar);
  }
  ///////////////// Event handlers //////////////////////////////
  _onSubmit() {
    if (this._formKey.currentState.validate()) {
      if (imageUrls.length < 1) {
        _showSnackBar('At least one image is needed!');
        return;
      }
      _formKey.currentState.save();

      _record.link = _record.link ?? '';

      // If user signed in add record
      if (widget.signedInUser != null) {
        _record.userId = widget.signedInUser.uuid;
        _record.beneficiaryId = _beneficiary.id;
        _record.photos = imageUrls;

        // If 'add' mode
        if (bAddOrEdit == true) {
          _addRecord();
        } else {
          _updateRecord();
        }
      }
      // If user not signed in go to login modal
      else {
        _showSnackBar('You need to login to add record');
        return;
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
    if (_imageFile == null) {
      return;
    }

    /////////// Upload to firebase storage //////////
    setState(() {
      isUploadingImage = true;
    });

    final uuid = Uuid().v1();
    StorageReference reference = firebaseStorage.ref().child("image-$uuid");
    //Upload the file to firebase
    StorageUploadTask uploadTask = reference.putFile(_imageFile);

    // Waits till the file is uploaded then stores the download url
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

    String _downloadUrl = await taskSnapshot.ref.getDownloadURL();
    setState(() {
      imageUrls.add(_downloadUrl);
      isUploadingImage = false;
    });
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
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                TextFormField(
                  initialValue: _record.amount != null? _record.amount.toString() : '',
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
                  initialValue: _record.title != null? _record.title.toString() : '',
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
                  initialValue: _record.description != null? _record.description.toString() : '',
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
                  initialValue: _record.city != null? _record.city.toString() : '',
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
                  initialValue: _record.zip != null? _record.zip.toString() : '',
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
                  initialValue: _record.link != null? _record.link.toString() : '',
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
                        onPressed: isUploadingImage ? null : () {
                          _onAddImage(ImageSource.gallery);
                        },
                        icon: Icon(Icons.photo_library),
                        label: isUploadingImage ? Text('Hold on...'): Text('Library image'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: RaisedButton.icon(
                        onPressed: isUploadingImage ? null : () {
                          _onAddImage(ImageSource.camera);
                        },
                        icon: Icon(Icons.camera_alt),
                        label: isUploadingImage ? Text('Hold on...') : Text('Camera image'),
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
            FlatButton.icon(icon: Icon(FontAwesomeIcons.solidSave), onPressed: _onSubmit, label: bAddOrEdit ? Text("Submit") : Text("Update")),
            FlatButton.icon(icon: Icon(FontAwesomeIcons.solidTimesCircle), onPressed: () {}, label: Text("Cancel")),
          ],
        ),
      ),
    );
  }
}