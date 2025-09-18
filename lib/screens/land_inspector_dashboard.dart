import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:land_registration/providers/LandRegisterModel.dart';
import 'package:land_registration/screens/transferOwnership.dart';
import 'package:land_registration/widget/menu_item_tile.dart';
import 'package:provider/provider.dart';
import '../constant/utils.dart';
import '../providers/MetamaskProvider.dart';

class LandInspector extends StatefulWidget {
  const LandInspector({Key? key}) : super(key: key);

  @override
  _LandInspectorState createState() => _LandInspectorState();
}

class _LandInspectorState extends State<LandInspector> {
  var model, model2;
  final colors = <Color>[Colors.indigo, Colors.blue, Colors.orange, Colors.red];
  List<List<dynamic>> userData = [];
  List<List<dynamic>> landData = [];
  List<List<dynamic>> paymenList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int screen = 0;
  bool isFirstTimeLoad = true;
  dynamic userCount = -1, landCount = -1;
  bool isLoading = false;

  List<Menu> menuItems = [
    Menu(title: 'Dashboard', icon: Icons.dashboard),
    Menu(title: 'Verify User', icon: Icons.verified_user),
    Menu(title: 'Verify Land', icon: Icons.web),
    Menu(title: 'Transfer Ownership', icon: Icons.transform),
    Menu(title: 'Logout', icon: Icons.logout),
  ];

  getUserCount() async {
    if (connectedWithMetamask) {
      userCount = await model2.userCount();
      landCount = await model2.landCount();
    } else {
      userCount = await model.userCount();
      landCount = await model.landCount();
    }
    isFirstTimeLoad = false;
    setState(() {});
  }

  Widget getCurrentScreen() {
    if (screen == -1) return const Center(child: CircularProgressIndicator());
    if (screen == 0) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _container(0),
              _container(1),
              _container(2),
            ],
          ),
        ],
      );
    }
    if (screen == 1) {
      return Container(padding: const EdgeInsets.all(16), child: userList());
    }
    if (screen == 2) {
      return Container(padding: const EdgeInsets.all(16), child: landList());
    }
    if (screen == 3) {
      return Container(
          padding: const EdgeInsets.all(16), child: transferOwnershipWidget());
    }
    return Container();
  }

  Widget _container(int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colors[index],
      child: Container(
        width: 500,
        height: 140,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0)
              Text(
                userCount == -1 ? 'Loading...' : userCount.toString(),
                style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            if (index == 0)
              const Text('Total Users Registered',
                  style: TextStyle(fontSize: 16, color: Colors.white70)),
            if (index == 1)
              Text(
                landCount == -1 ? 'Loading...' : landCount.toString(),
                style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            if (index == 1)
              const Text('Total Property Registered',
                  style: TextStyle(fontSize: 16, color: Colors.white70)),
            if (index == 2)
              const Text('Total Property Transfered',
                  style: TextStyle(fontSize: 16, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    model = Provider.of<LandRegisterModel>(context);
    model2 = Provider.of<MetaMaskProvider>(context);
    if (isFirstTimeLoad) {
      getUserCount();
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("LandInspector Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        leading: isDesktop
            ? Container()
            : GestureDetector(
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.menu, color: Colors.white),
                ),
                onTap: () => _scaffoldKey.currentState!.openDrawer(),
              ),
      ),
      drawer: drawer2(),
      drawerScrimColor: Colors.transparent,
      body: Container(
        color: const Color(0xFFF4F6F8),
        child: Row(
          children: [
            isDesktop ? drawer2() : Container(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: getCurrentScreen(),
              ),
            )
          ],
        ),
      ),
    );
  }

  getLandList() async {
    setState(() {
      landData = [];
      isLoading = true;
    });
    List<dynamic> landList;
    if (connectedWithMetamask) {
      landList = await model2.allLandList();
    } else {
      landList = await model.allLandList();
    }

    List<dynamic> temp;
    for (int i = 0; i < landList.length; i++) {
      if (connectedWithMetamask) {
        temp = await model2.landInfo(landList[i]);
      } else {
        temp = await model.landInfo(landList[i]);
      }
      landData.add(temp);
      isLoading = false;
      setState(() {});
    }

    // // //screen = 2;
    setState(() {});
  }

  Widget landList() {
    return ListView.builder(
      itemCount: landData == null ? 1 : landData.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Column(
            children: [
              const Divider(height: 15),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '#',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: Text(
                          'Owner Address',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          'Area',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          'Price',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          'PID',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          'SurveyNo.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          'Document',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          'Verify',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const Divider(height: 15),
            ],
          );
        }

        index -= 1;
        List<dynamic> data = landData[index];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text((index + 1).toString()),
              ),
              Expanded(
                flex: 5,
                child: Center(child: Text(data[9].toString())),
              ),
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    data[2].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(child: Text(data[3].toString())),
              ),
              Expanded(
                flex: 2,
                child: Center(child: Text(data[5].toString())),
              ),
              Expanded(
                flex: 2,
                child: Center(child: Text(data[6].toString())),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      launchUrl(data[7].toString());
                    },
                    child: const Text(
                      'View Document',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: data[10]
                      ? const Text('Verified',
                          style: TextStyle(color: Colors.green))
                      : ElevatedButton(
                          onPressed: () async {
                            SmartDialog.showLoading();
                            try {
                              if (connectedWithMetamask) {
                                await model2.verifyLand(data[0]);
                              } else {
                                await model.verifyLand(data[0]);
                              }
                              await getLandList();
                            } catch (e) {
                              print(e);
                            }
                            SmartDialog.dismiss();
                          },
                          child: const Text('Verify'),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getUserList() async {
    setState(() {
      userData = [];
      isLoading = true;
    });

    List<dynamic> userList;
    if (connectedWithMetamask) {
      userList = await model2.allUsers();
    } else {
      userList = await model.allUsers();
    }

    List<dynamic> temp;
    for (int i = 0; i < userList.length; i++) {
      if (connectedWithMetamask) {
        temp = await model2.userInfo(userList[i].toString());
      } else {
        temp = await model.userInfo(userList[i].toString());
      }
      userData.add(temp);
      isLoading = false;
      setState(() {});
    }
    setState(() {
      // // //screen = 1;
      isLoading = false;
    });
  }

  Widget userList() {
    return ListView.builder(
      itemCount: userData == null ? 1 : userData.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              const Divider(height: 20, thickness: 2, color: Colors.black),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                color: Colors.grey[100],
                child: Row(
                  children: const [
                    Expanded(
                      flex: 1,
                      child: Text('#',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87)),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text('Address',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Id Number',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Phone Number',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Document',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Verify',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 15, thickness: 2, color: Colors.black),
            ],
          );
        }

        index -= 1;
        List<dynamic> data = userData[index];
        return Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 0.5, color: Colors.grey),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text((index + 1).toString(),
                    style: const TextStyle(fontSize: 14)),
              ),
              Expanded(
                flex: 5,
                child: Text(data[0].toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ),
              Expanded(
                flex: 3,
                child: Text(data[1].toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ),
              Expanded(
                flex: 2,
                child: Text(data[4].toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13)),
              ),
              Expanded(
                flex: 2,
                child: Text(data[5].toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13)),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      launchUrl(data[6].toString());
                    },
                    child: const Text('View',
                        style: TextStyle(color: Colors.blue, fontSize: 13)),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: data[8]
                      ? const Text('Verified',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13))
                      : ElevatedButton(
                          onPressed: () async {
                            SmartDialog.showLoading();
                            try {
                              if (connectedWithMetamask) {
                                await model2.verifyUser(data[0].toString());
                              } else {
                                await model.verifyUser(data[0].toString());
                              }
                              await getUserList();
                            } catch (e) {
                              print(e);
                            }
                            SmartDialog.dismiss();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text('Verify',
                              style: TextStyle(fontSize: 13)),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> paymentDoneList() async {
    //SmartDialog.showLoading();
    try {
      setState(() {
        isLoading = true;
        paymenList = [];
      });
      List<dynamic> list;
      if (connectedWithMetamask) {
        list = await model2.paymentDoneList();
      } else {
        list = await model.paymentDoneList();
      }

      List<dynamic> temp;
      for (int i = 0; i < list.length; i++) {
        if (connectedWithMetamask) {
          temp = await model2.requestInfo(list[i]);
        } else {
          temp = await model.requestInfo(list[i]);
        }
        paymenList.add(temp);
        setState(() {
          isLoading = false;
        });
      }
      // // //screen = 3;
      setState(() {});
    } catch (e) {
      print("\n\n$e\n");
      showToast('Something went wrong', backgroundColor: Colors.redAccent);
    }
    // // //SmartDialog.dismiss();
    setState(() {});
    //return allInfo;
  }

  Widget transferOwnershipWidget() {
    return ListView.builder(
      itemCount: paymenList == null ? 1 : paymenList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Ownership Transfer Requests",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 15, thickness: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: const [
                    Expanded(
                      child: Text('#',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 1,
                    ),
                    Expanded(
                      child: Text('Land Id',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      flex: 1,
                    ),
                    Expanded(
                      child: Center(
                        child: Text('Seller Address',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      flex: 6,
                    ),
                    Expanded(
                      child: Center(
                        child: Text('Buyer Address',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      flex: 6,
                    ),
                    Expanded(
                      child: Center(
                        child: Text('Status',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      flex: 2,
                    ),
                    Expanded(
                      child: Center(
                        child: Text('Action',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      flex: 3,
                    )
                  ],
                ),
              ),
              const Divider(height: 15, thickness: 1)
            ],
          );
        }

        index -= 1;
        List<dynamic> data = paymenList[index];

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(width: 0.5, color: Colors.grey.shade300)),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(child: Text((index + 1).toString()), flex: 1),
              Expanded(
                child: Center(child: Text(data[3].toString())),
                flex: 1,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    data[1].toString(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                flex: 6,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    data[2].toString(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                flex: 6,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    data[4].toString() == '3' ? 'Payment Done' : 'Completed',
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                flex: 2,
              ),
              Expanded(
                child: Center(
                  child: data[4].toString() == '4'
                      ? const Text('Transferred',
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold))
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            SmartDialog.showLoading();
                            try {
                              List<CameraDescription> camerasList =
                                  await availableCameras();
                              SmartDialog.dismiss();
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => transferOwnership(
                                    reqId: data[0].toString(),
                                    sellerAdd: data[1].toString(),
                                    landId: data[3].toString(),
                                    buyerAdd: data[2].toString(),
                                    cameraList: camerasList,
                                  ),
                                ),
                              );
                              await paymentDoneList();
                            } catch (e) {
                              SmartDialog.dismiss();
                              showToast(
                                  "Something Went Wrong\nCamera Exception",
                                  context: context,
                                  backgroundColor: Colors.red);
                            }
                          },
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          label: const Text('Transfer'),
                        ),
                ),
                flex: 3,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget drawer2() {
    return Drawer(
      child: Container(
        color: const Color(0xFF1F2937),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.person, size: 80, color: Colors.white),
            const SizedBox(height: 12),
            const Text('Land Inspector',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.separated(
                itemCount: menuItems.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: Colors.white30),
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(menuItems[index].icon,
                      color: screen == index ? Colors.amber : Colors.white),
                  title: Text(menuItems[index].title,
                      style: TextStyle(
                          color:
                              screen == index ? Colors.amber : Colors.white)),
                  onTap: () {
                    if (index == 4) {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/');
                    }
                    if (index == 0) getUserCount();
                    if (index == 1) getUserList();
                    if (index == 2) getLandList();
                    if (index == 3) paymentDoneList();
                    setState(() => screen = index);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}
