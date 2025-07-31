import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:land_registration/constant/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import '../providers/LandRegisterModel.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_search/mapbox_search.dart';
import '../constant/utils.dart';
import '../providers/MetamaskProvider.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({Key? key}) : super(key: key);

  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  late String name, age, city, adharNumber, panNumber, email;

  double width = 590;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false, isAdded = false;
  List<MapBoxPlace> predictions = [];
  late PlacesSearch placesSearch;
  final FocusNode _focusNode = FocusNode();
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  TextEditingController addressController = TextEditingController();

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 540,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 45.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: List.generate(
                predictions.length,
                (index) => ListTile(
                  title: Text(predictions[index].placeName.toString()),
                  onTap: () {
                    addressController.text =
                        predictions[index].placeName.toString();
                    setState(() {});
                    _overlayEntry.remove();
                    _overlayEntry.dispose();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> autocomplete(value) async {
    List<MapBoxPlace>? res = await placesSearch.getPlaces(value);
    if (res != null) predictions = res;
    setState(() {});
  }

  @override
  void initState() {
    placesSearch = PlacesSearch(
      apiKey: mapBoxApiKey,
      limit: 10,
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context)!.insert(_overlayEntry);
      } else {
        _overlayEntry.remove();
      }
    });
    super.initState();
  }

  Widget customTextField(String label, String hint, Function(String) onChanged,
      {bool isNumber = false,
      String? Function(String?)? validator,
      TextEditingController? controller,
      FocusNode? focusNode}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: validator ??
            (val) => val == null || val.isEmpty ? 'Required' : null,
        onChanged: onChanged,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters:
            isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<LandRegisterModel>(context);
    var model2 = Provider.of<MetaMaskProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 25, 132, 255),
        centerTitle: true,
        title: const Text('User Registration'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: width,
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Blockchain Title Deed Registry',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Please register to proceed',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  customTextField('Name', 'Enter Name', (val) => name = val),
                  customTextField('Age', 'Enter Age', (val) => age = val,
                      isNumber: true),
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: customTextField(
                      'Address',
                      'Enter Address',
                      (val) {
                        if (val.isNotEmpty) {
                          autocomplete(val);
                          _overlayEntry.remove();
                          _overlayEntry = _createOverlayEntry();
                          Overlay.of(context)!.insert(_overlayEntry);
                        } else {
                          if (predictions.isNotEmpty && mounted) {
                            setState(() {
                              predictions = [];
                            });
                          }
                        }
                      },
                      controller: addressController,
                      focusNode: _focusNode,
                    ),
                  ),
                  customTextField('Id Number', 'Enter ID Number',
                      (val) => adharNumber = val, isNumber: true,
                      validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter ID Number';
                    if (value.length != 8)
                      return 'Please enter Valid ID number';
                    return null;
                  }),
                  customTextField('Mobile Number', 'Enter Mobile Number',
                      (val) => panNumber = val, isNumber: true,
                      validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter Mobile Number';
                    if (value.length != 10)
                      return 'Please enter Valid Mobile number';
                    return null;
                  }),
                  customTextField('Email', 'Enter Email', (val) => email = val,
                      validator: (value) {
                    RegExp regex = RegExp(
                        r"^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                        r"{0,253}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                        r"{0,253}[a-zA-Z0-9])?)*");
                    if (!regex.hasMatch(value ?? ''))
                      return 'Enter a valid email address';
                    return null;
                  }),
                  const SizedBox(height: 20),
                  isAdded
                      ? Center(
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/user'),
                            child: const Text('Continue to Login'),
                          ),
                        )
                      : Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 14),
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => isLoading = true);
                                      try {
                                        if (connectedWithMetamask) {
                                          await model2.registerUser(
                                              name,
                                              age,
                                              addressController.text,
                                              adharNumber,
                                              panNumber,
                                              '',
                                              email);
                                        } else {
                                          await model.registerUser(
                                              name,
                                              age,
                                              addressController.text,
                                              adharNumber,
                                              panNumber,
                                              '',
                                              email);
                                        }
                                        showToast("Successfully Registered",
                                            context: context,
                                            backgroundColor: Colors.green);
                                        setState(() => isAdded = true);
                                      } catch (e) {
                                        print(e);
                                        showToast("Something Went Wrong",
                                            context: context,
                                            backgroundColor: Colors.red);
                                      }
                                      setState(() => isLoading = false);
                                    }
                                  },
                            child: const Text('Register',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
