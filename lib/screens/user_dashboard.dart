import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:land_registration/providers/LandRegisterModel.dart';
import 'package:land_registration/constant/loadingScreen.dart';
import 'package:land_registration/screens/ChooseLandMap.dart';
import 'package:land_registration/screens/viewLandDetails.dart';
import 'package:land_registration/widget/land_container.dart';
import 'package:land_registration/widget/menu_item_tile.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:provider/provider.dart';
import '../providers/MetamaskProvider.dart';
import '../constant/constants.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:http/http.dart' as http;
import '../constant/utils.dart';

class UserDashBoard extends StatefulWidget {
  const UserDashBoard({Key? key}) : super(key: key);

  @override
  _UserDashBoardState createState() => _UserDashBoardState();
}

class _UserDashBoardState extends State<UserDashBoard> {
  var model, model2;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int screen = 0;
  late List<dynamic> userInfo;
  bool isLoading = true, isUserVerified = false;
  bool isUpdated = true;
  List<List<dynamic>> LandGall = [];
  String name = "";

  final _formKey = GlobalKey<FormState>();
  late String area,
      landAddress,
      landPrice,
      propertyID,
      surveyNo,
      document,
      allLatiLongi;
  List<List<dynamic>> landInfo = [];
  List<List<dynamic>> receivedRequestInfo = [];
  List<List<dynamic>> sentRequestInfo = [];
  List<dynamic> prices = [];
  List<Menu> menuItems = [
    Menu(title: 'Dashboard', icon: Icons.dashboard),
    Menu(title: 'Add Lands', icon: Icons.add_chart),
    Menu(title: 'My Lands', icon: Icons.landscape_rounded),
    Menu(title: 'Land Gallery', icon: Icons.landscape_rounded),
    Menu(title: 'My Received Request', icon: Icons.request_page_outlined),
    Menu(title: 'My Sent Land Request', icon: Icons.request_page_outlined),
    Menu(title: 'Logout', icon: Icons.logout),
  ];
  Map<String, String> requestStatus = {
    '0': 'Pending',
    '1': 'Accepted',
    '2': 'Rejected',
    '3': 'Payment Done',
    '4': 'Completed'
  };

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
                offset: const Offset(0.0, 40 + 5.0),
                child: Material(
                  elevation: 4.0,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: List.generate(
                        predictions.length,
                        (index) => ListTile(
                              title:
                                  Text(predictions[index].placeName.toString()),
                              onTap: () {
                                addressController.text =
                                    predictions[index].placeName.toString();

                                setState(() {});
                                _overlayEntry.remove();
                                _overlayEntry.dispose();
                              },
                            )),
                  ),
                ),
              ),
            ));
  }

  Future<void> autocomplete(value) async {
    List<MapBoxPlace>? res = await placesSearch.getPlaces(value);
    if (res != null) predictions = res;
    setState(() {});
    // print(res);
    // print(res![0].placeName);
    // print(res![0].geometry!.coordinates);
    // print(res![0]);
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

  getLandInfo() async {
    setState(() {
      landInfo = [];
      isLoading = true;
    });
    List<dynamic> landList;
    if (connectedWithMetamask) {
      landList = await model2.myAllLands();
    } else {
      landList = await model.myAllLands();
    }

    List<List<dynamic>> info = [];
    List<dynamic> temp;
    for (int i = 0; i < landList.length; i++) {
      if (connectedWithMetamask) {
        temp = await model2.landInfo(landList[i]);
      } else {
        temp = await model.landInfo(landList[i]);
      }
      landInfo.add(temp);
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  getLandGallery() async {
    setState(() {
      isLoading = true;
      LandGall = [];
    });
    List<dynamic> landList;
    if (connectedWithMetamask) {
      landList = await model2.allLandList();
    } else {
      landList = await model.allLandList();
    }

    // List<List<dynamic>> allInfo = [];
    List<dynamic> temp;
    for (int i = 0; i < landList.length; i++) {
      if (connectedWithMetamask) {
        temp = await model2.landInfo(landList[i]);
      } else {
        temp = await model.landInfo(landList[i]);
      }
      LandGall.add(temp);
      setState(() {
        isLoading = false;
      });
    }
    // screen = 3;
    isLoading = false;
    setState(() {});
  }

  getMySentRequest() async {
    //SmartDialog.showLoading();
    sentRequestInfo = [];
    setState(() {
      isLoading = true;
    });
    await getEthToInr();
    List<dynamic> requestList;
    if (connectedWithMetamask) {
      requestList = await model2.mySentRequest();
    } else {
      requestList = await model.mySentRequest();
    }

    List<dynamic> temp;
    var pri;
    for (int i = 0; i < requestList.length; i++) {
      if (connectedWithMetamask) {
        temp = await model2.requestInfo(requestList[i]);
        pri = await model2.landPrice(temp[3]);
      } else {
        temp = await model.requestInfo(requestList[i]);
        pri = await model.landPrice(temp[3]);
      }
      prices.add(pri);
      sentRequestInfo.add(temp);
      isLoading = false;

      // SmartDialog.dismiss();
      setState(() {});
    }

    // screen = 5;
    isLoading = false;

    // SmartDialog.dismiss();
    setState(() {});
  }

  getMyReceivedRequest() async {
    receivedRequestInfo = [];
    setState(() {
      isLoading = true;
    });
    List<dynamic> requestList;
    if (connectedWithMetamask) {
      requestList = await model2.myReceivedRequest();
    } else {
      requestList = await model.myReceivedRequest();
    }

    List<dynamic> temp;
    for (int i = 0; i < requestList.length; i++) {
      if (connectedWithMetamask) {
        temp = await model2.requestInfo(requestList[i]);
      } else {
        temp = await model.requestInfo(requestList[i]);
      }
      receivedRequestInfo.add(temp);
      isLoading = false;
      setState(() {});
    }
    isLoading = false;
    //  screen = 4;
    setState(() {});
  }

  Future<void> getProfileInfo() async {
    // setState(() {
    //   isLoading = true;
    // });
    if (connectedWithMetamask) {
      userInfo = await model2.myProfileInfo();
    } else {
      userInfo = await model.myProfileInfo();
    }
    name = userInfo[1];
    setState(() {
      isLoading = false;
    });
  }

  String docuName = "";
  late PlatformFile documentFile;
  String cid = "", docUrl = "";
  bool isFilePicked = false;

  pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf'],
    );

    if (result != null) {
      isFilePicked = true;
      docuName = result.files.single.name;
      documentFile = result.files.first;
    }
    setState(() {});
  }

  Future<bool> uploadDocument() async {
    String url = "https://api.nft.storage/upload";
    var header = {"Authorization": "Bearer $nftStorageApiKey"};

    if (isFilePicked) {
      try {
        final response = await http.post(Uri.parse(url),
            headers: header, body: documentFile.bytes);
        var data = jsonDecode(response.body);
        //print(data);
        if (data['ok']) {
          cid = data["value"]["cid"];
          docUrl = "https://" + cid + ".ipfs.dweb.link";

          return true;
        }
      } catch (e) {
        print(e);
        showToast("Something went wrong,while document uploading",
            context: context, backgroundColor: Colors.red);
      }
    } else {
      showToast("Choose Document",
          context: context, backgroundColor: Colors.red);
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    model = Provider.of<LandRegisterModel>(context);
    model2 = Provider.of<MetaMaskProvider>(context);
    if (isUpdated) {
      getProfileInfo();
      isUpdated = false;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        leading: isDesktop
            ? Container()
            : GestureDetector(
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.menu,
                    color: Colors.white,
                  ), //AnimatedIcon(icon: AnimatedIcons.menu_arrow,progress: _animationController,),
                ),
                onTap: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
              ),
        title: const Text('User Dashboard'),
      ),
      drawer: drawer2(),
      drawerScrimColor: Colors.transparent,
      body: Container(
        color: const Color(0xFFF4F6F8),
        child: Row(
          children: [
            isDesktop
                ? drawer2()
                : Container(), // show permanent drawer on desktop
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: screen == 0
                    ? userProfile()
                    : screen == 1
                        ? addLand()
                        : screen == 2
                            ? myLands()
                            : screen == 3
                                ? landGallery()
                                : screen == 4
                                    ? Padding(
                                        padding: const EdgeInsets.all(25),
                                        child: receivedRequest(),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(25),
                                        child: sentRequest(),
                                      ),
              ),
            ),
          ],
        ),
      ), /*  */
    );
  }

  Widget sentRequest() {
    return ListView.builder(
      itemCount: sentRequestInfo == null ? 1 : sentRequestInfo.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Column(
            children: [
              const Divider(
                height: 15,
              ),
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      '#',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Text(
                      'Land Id',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                      child: Center(
                        child: Text('Owner Address',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      flex: 5),
                  Expanded(
                    child: Center(
                      child: Text('Status',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Price(in Ksh)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    flex: 2,
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Make Payment',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    flex: 2,
                  )
                ],
              ),
              const Divider(
                height: 15,
              )
            ],
          );
        }
        index -= 1;
        List<dynamic> data = sentRequestInfo[index];
        return Container(
          height: 60,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text((index + 1).toString()),
                flex: 1,
              ),
              Expanded(child: Center(child: Text(data[3].toString())), flex: 1),
              Expanded(
                  child: Center(
                    child: Text(data[1].toString()),
                  ),
                  flex: 5),
              Expanded(
                  child: Center(
                    child: Text(requestStatus[data[4].toString()].toString()),
                  ),
                  flex: 3),
              Expanded(
                  child: Center(
                    child: Text(prices[index].toString()),
                  ),
                  flex: 2),
              Expanded(
                  child: Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.green),
                        onPressed: data[4].toString() != '1'
                            ? null
                            : () async {
                                _paymentDialog(
                                    data[2],
                                    data[1],
                                    prices[index].toString(),
                                    double.parse(prices[index].toString()) /
                                        ethToInr,
                                    ethToInr,
                                    data[0]);
                                // SmartDialog.showLoading();
                                // try {
                                //   //await model.rejectRequest(data[0]);
                                //   //await getMyReceivedRequest();
                                // } catch (e) {
                                //   print(e);
                                // }
                                //
                                // //await Future.delayed(Duration(seconds: 2));
                                // SmartDialog.dismiss();
                              },
                        child: const Text('Make Payment')),
                  ),
                  flex: 2),
            ],
          ),
        );
      },
    );
  }

  Widget receivedRequest() {
    return ListView.builder(
      itemCount:
          receivedRequestInfo == null ? 1 : receivedRequestInfo.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Column(
            children: [
              const Divider(
                height: 15,
              ),
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      '#',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Text(
                      'Land Id',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    flex: 1,
                  ),
                  Expanded(
                      child: Center(
                        child: Text('Buyer Address',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      flex: 5),
                  Expanded(
                    child: Center(
                      child: Text('Status',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    flex: 3,
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Payment Done',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    flex: 2,
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Reject',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    flex: 2,
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Accept',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    flex: 2,
                  )
                ],
              ),
              const Divider(
                height: 15,
              )
            ],
          );
        }
        index -= 1;
        List<dynamic> data = receivedRequestInfo[index];
        return Container(
          height: 60,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text((index + 1).toString()),
                flex: 1,
              ),
              Expanded(child: Center(child: Text(data[3].toString())), flex: 1),
              Expanded(
                  child: Center(
                    child: Text(data[2].toString()),
                  ),
                  flex: 5),
              Expanded(
                  child: Center(
                    child: Text(requestStatus[data[4].toString()].toString()),
                  ),
                  flex: 3),
              Expanded(child: Center(child: Text(data[5].toString())), flex: 2),
              Expanded(
                  child: Center(
                    child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(primary: Colors.redAccent),
                        onPressed: data[4].toString() != '0'
                            ? null
                            : () async {
                                SmartDialog.showLoading();
                                try {
                                  if (connectedWithMetamask) {
                                    await model2.rejectRequest(data[0]);
                                  } else {
                                    await model.rejectRequest(data[0]);
                                  }
                                  await getMyReceivedRequest();
                                } catch (e) {
                                  print(e);
                                }

                                //await Future.delayed(Duration(seconds: 2));
                                SmartDialog.dismiss();
                              },
                        child: const Text('Reject')),
                  ),
                  flex: 2),
              Expanded(
                  child: Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.greenAccent),
                        onPressed: data[4].toString() != '0'
                            ? null
                            : () async {
                                SmartDialog.showLoading();
                                try {
                                  if (connectedWithMetamask) {
                                    await model2.acceptRequest(data[0]);
                                  } else {
                                    await model.acceptRequest(data[0]);
                                  }
                                  await getMyReceivedRequest();
                                } catch (e) {
                                  print(e);
                                }

                                //await Future.delayed(Duration(seconds: 2));
                                SmartDialog.dismiss();
                              },
                        child: const Text('Accept')),
                  ),
                  flex: 2),
            ],
          ),
        );
      },
    );
  }

  Widget landGallery() {
    if (isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (LandGall.isEmpty) {
      return const Expanded(
          child: Center(
              child: Text(
        'No Lands Added yet',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      )));
    }
    return Expanded(
      child: Center(
        child: SizedBox(
          width: isDesktop ? 900 : width,
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            scrollDirection: Axis.vertical,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent: 440,
                crossAxisCount: isDesktop ? 2 : 1,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20),
            itemCount: LandGall.length,
            itemBuilder: (context, index) {
              return landWid2(
                  LandGall[index][10],
                  LandGall[index][1].toString(),
                  LandGall[index][2].toString(),
                  LandGall[index][3].toString(),
                  LandGall[index][9] == userInfo[0],
                  LandGall[index][8], () async {
                if (isUserVerified) {
                  SmartDialog.showLoading();
                  try {
                    if (connectedWithMetamask) {
                      await model2.sendRequestToBuy(LandGall[index][0]);
                    } else {
                      await model.sendRequestToBuy(LandGall[index][0]);
                    }
                    showToast("Request sent",
                        context: context, backgroundColor: Colors.green);
                  } catch (e) {
                    print(e);
                    showToast("Something Went Wrong",
                        context: context, backgroundColor: Colors.red);
                  }
                  SmartDialog.dismiss();
                } else {
                  showToast("You are not verified",
                      context: context, backgroundColor: Colors.red);
                }
              }, () {
                List<String> allLatiLongi =
                    LandGall[index][4].toString().split('|');

                LandInfo landinfo = LandInfo(
                    LandGall[index][1].toString(),
                    LandGall[index][2].toString(),
                    LandGall[index][3].toString(),
                    LandGall[index][5].toString(),
                    LandGall[index][6].toString(),
                    LandGall[index][7].toString(),
                    LandGall[index][8],
                    LandGall[index][9].toString(),
                    LandGall[index][10]);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewLandDetails(
                              allLatitude: allLatiLongi[0],
                              allLongitude: allLatiLongi[1],
                              landinfo: landinfo,
                            )));
              });
            },
          ),
        ),
      ),
    );
  }

  Widget myLands() {
    if (isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }
    if (landInfo.isEmpty) {
      return const Expanded(
          child: Center(
              child: Text(
        'No Lands Added yet',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      )));
    }
    return Expanded(
      child: Center(
        child: SizedBox(
          width: isDesktop ? 900 : width,
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            scrollDirection: Axis.vertical,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent: 440,
                crossAxisCount: isDesktop ? 2 : 1,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20),
            itemCount: landInfo.length,
            itemBuilder: (context, index) {
              return landWid(
                  landInfo[index][10],
                  landInfo[index][1].toString(),
                  landInfo[index][2].toString(),
                  landInfo[index][3].toString(),
                  landInfo[index][8],
                  () =>
                      confirmDialog('Are you sure to make it on sell?', context,
                          () async {
                        SmartDialog.showLoading();
                        if (connectedWithMetamask) {
                          await model2.makeForSell(landInfo[index][0]);
                        } else {
                          await model.makeForSell(landInfo[index][0]);
                        }
                        Navigator.pop(context);
                        await getLandInfo();
                        SmartDialog.dismiss();
                      }));
            },
          ),
        ),
      ),
    );
  }

 Widget _buildTextField({
  required String label,
  required String hint,
  String? validatorMsg,
  TextInputType? keyboardType,
  void Function(String)? onChanged,
  TextEditingController? controller,
  FocusNode? focusNode,
  TextInputFormatter? inputFormatter,
  IconData? prefixIcon,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      style: const TextStyle(fontSize: 16),
      keyboardType: keyboardType,
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      inputFormatters: inputFormatter != null ? [inputFormatter] : [],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorMsg ?? 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.grey.shade600)
            : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        labelStyle: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
      ),
    ),
  );
}


  Widget addLand() {
    return Center(
      widthFactor: isDesktop ? 2 : 1,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade300),
        ),
        width: width,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Land Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Area (SqFt)',
                hint: 'Enter Area in SqFt',
                validatorMsg: 'Please enter area',
                keyboardType: TextInputType.number,
                onChanged: (val) => area = val,
                inputFormatter: FilteringTextInputFormatter.digitsOnly,
              ),
              _buildTextField(
                label: 'Address',
                hint: 'Enter Land Address',
                controller: addressController,
                validatorMsg: 'Please enter Land Address',
                focusNode: _focusNode,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    autocomplete(value);
                    _overlayEntry.remove();
                    _overlayEntry = _createOverlayEntry();
                    Overlay.of(context)!.insert(_overlayEntry);
                  } else if (predictions.isNotEmpty && mounted) {
                    setState(() => predictions = []);
                  }
                },
              ),
              _buildTextField(
                label: 'Land Price',
                hint: 'Enter Land Price',
                validatorMsg: 'Please enter Land Price',
                keyboardType: TextInputType.number,
                onChanged: (val) => landPrice = val,
                inputFormatter: FilteringTextInputFormatter.digitsOnly,
              ),
              _buildTextField(
                label: 'PID',
                hint: 'Enter Property ID',
                validatorMsg: 'Please enter PID',
                keyboardType: TextInputType.number,
                onChanged: (val) => propertyID = val,
                inputFormatter: FilteringTextInputFormatter.digitsOnly,
              ),
              _buildTextField(
                label: 'Survey No.',
                hint: 'Survey Number',
                validatorMsg: 'Please enter Survey Number',
                onChanged: (val) => surveyNo = val,
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.map),
                  label: const Text('Draw Land on Map'),
                  onPressed: () async {
                    allLatiLongi = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const landOnMap()),
                    );
                    if (allLatiLongi.isEmpty || allLatiLongi == "") {
                      showToast("Please select area on map",
                          context: context, backgroundColor: Colors.red);
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: CustomButton(
                  'Add',
                  isLoading || !isUserVerified
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate() &&
                              allLatiLongi.isNotEmpty &&
                              allLatiLongi != "") {
                            setState(() => isLoading = true);
                            try {
                              if (connectedWithMetamask) {
                                await model2.addLand(
                                  area,
                                  addressController.text,
                                  allLatiLongi,
                                  landPrice,
                                  propertyID,
                                  surveyNo,
                                  "",
                                );
                              } else {
                                await model.addLand(
                                  area,
                                  addressController.text,
                                  allLatiLongi,
                                  landPrice,
                                  propertyID,
                                  surveyNo,
                                  "",
                                );
                              }
                              showToast("Land Successfully Added",
                                  context: context,
                                  backgroundColor: Colors.green);
                            } catch (e) {
                              print(e);
                              showToast("Something Went Wrong",
                                  context: context,
                                  backgroundColor: Colors.red);
                            }
                            setState(() => isLoading = false);
                          }
                        },
                ),
              ),
              if (!isUserVerified)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'You are not verified',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              if (isLoading) Center(child: spinkitLoader),
            ],
          ),
        ),
      ),
    );
  }

  Widget userProfile() {
    if (isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    isUserVerified = userInfo[8];

    return Expanded(
      child: Center(
        child: Container(
          width: width > 500 ? 500 : width * 0.9,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.shade100.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(2, 4),
              ),
            ],
            border: Border.all(color: Colors.blueAccent.shade100),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isUserVerified
                            ? Colors.green.shade100
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isUserVerified
                                ? Icons.verified
                                : Icons.info_outline,
                            color: isUserVerified
                                ? Colors.green
                                : Colors.blueAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isUserVerified ? 'Verified' : 'Not Verified',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isUserVerified
                                  ? Colors.green.shade700
                                  : Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                customTextField('Wallet Address', userInfo[0].toString(),
                    readOnly: true),
                const SizedBox(height: 12),
                customTextField('Name', userInfo[1].toString(), readOnly: true),
                const SizedBox(height: 12),
                customTextField('Age', userInfo[2].toString(), readOnly: true),
                const SizedBox(height: 12),
                customTextField('City', userInfo[3].toString(), readOnly: true),
                const SizedBox(height: 12),
                customTextField('ID Number', userInfo[4].toString(),
                    readOnly: true),
                const SizedBox(height: 12),
                customTextField('Mobile Number', userInfo[5].toString(),
                    readOnly: true),
                const SizedBox(height: 12),
                customTextField('Email', userInfo[7].toString(),
                    readOnly: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customTextField(
    String label,
    String value, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  Widget drawer2() {
    return Drawer(
      child: Container(
        color: const Color(0xFF1F2937), // dark background
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.person, size: 80, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              name, // dynamic user name
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.separated(
                itemCount: menuItems.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Colors.white30),
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(
                    menuItems[index].icon,
                    color: screen == index ? Colors.amber : Colors.white,
                  ),
                  title: Text(
                    menuItems[index].title,
                    style: TextStyle(
                      color: screen == index ? Colors.amber : Colors.white,
                    ),
                  ),
                  onTap: () {
                    if (index == 6) {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/');
                    }
                    if (index == 0) getProfileInfo();
                    if (index == 2) getLandInfo();
                    if (index == 3) getLandGallery();
                    if (index == 4) getMyReceivedRequest();
                    if (index == 5) getMySentRequest();

                    setState(() {
                      screen = index;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  _paymentDialog(buyerAdd, sellAdd, amountINR, total, ethval, reqID) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.white,
              child: Container(
                margin: const EdgeInsets.all(10),
                height: 430.0,
                width: 320,
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'Confirm Payment',
                      style: TextStyle(fontSize: 30),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      buyerAdd.toString(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13.0,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Icon(
                      Icons.arrow_circle_down,
                      size: 30,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      sellAdd.toString(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13.0,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Total Amount in Ksh",
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      amountINR,
                      style: const TextStyle(fontSize: 30),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      '1 ETH = ' + ethval.toString() + 'Ksh',
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Total ETH:",
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      total.toString(),
                      style: const TextStyle(fontSize: 30),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomButton3('Cancel', () {
                          Navigator.of(context).pop();
                        }, Colors.white),
                        CustomButton3('Confirm', () async {
                          SmartDialog.showLoading();
                          try {
                            if (connectedWithMetamask) {
                              await model2.makePayment(reqID, total);
                            } else {
                              await model.makePayment(reqID, total);
                            }
                            await getMySentRequest();
                            showToast("Payment Success",
                                context: context,
                                backgroundColor: Colors.green);
                          } catch (e) {
                            print(e);
                            showToast("Something Went Wrong",
                                context: context, backgroundColor: Colors.red);
                          }
                          SmartDialog.dismiss();
                          Navigator.of(context).pop();
                        }, Colors.blue)
                      ],
                    )
                  ],
                ),
              ));
        });
  }
}
