import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:land_registration/providers/LandRegisterModel.dart';
import 'package:land_registration/widget/menu_item_tile.dart';
import 'package:provider/provider.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/services.dart';

//addlandinspector ui

import '../constant/utils.dart';
import '../providers/MetamaskProvider.dart';

class AddLandInspector extends StatefulWidget {
  const AddLandInspector({Key? key}) : super(key: key);

  @override
  _AddLandInspectorState createState() => _AddLandInspectorState();
}

class _AddLandInspectorState extends State<AddLandInspector> {
  Widget customTextField(
    String label,
    String hint,
    Function(String) onChanged, {
    bool isNumber = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
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

  late String address, name, age, desig, city, newaddress;
  var model, model2;
  double width = 490;
  int screen = 0;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Menu> menuItems = [
    Menu(title: 'Add Land Inspector', icon: Icons.person_add),
    Menu(title: 'All Land Inspectors', icon: Icons.group),
    Menu(title: 'Change Contract Owner', icon: Icons.change_circle),
    Menu(title: 'Logout', icon: Icons.logout),
  ];

  List<List<dynamic>> allLandInspectorInfo = [];

  @override
  Widget build(BuildContext context) {
    model = Provider.of<LandRegisterModel>(context);
    model2 = Provider.of<MetaMaskProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: const Text(
          'Add Land Inspector',
        ),
      ),
      drawer: drawer2(),
      drawerScrimColor: Colors.transparent,
      body: Row(
        children: [
          if (isDesktop) drawer2(),
          Expanded(
            child: Center(
              child: screen == 0
                  ? addLandInspector()
                  : screen == 1
                      ? Container(
                          padding: const EdgeInsets.all(25),
                          child: landInspectorList(),
                        )
                      : changeContractOwner(),
            ),
          )
        ],
      ),
    );
  }

  getLandInspectorInfo() async {
    setState(() {
      isLoading = true;
    });
    List<dynamic> landList;
    if (connectedWithMetamask)
      landList = await model2.allLandInspectorList();
    else
      landList = await model.allLandInspectorList();

    List<List<dynamic>> info = [];
    List<dynamic> temp;
    for (int i = 0; i < landList.length; i++) {
      if (connectedWithMetamask)
        temp = await model2.landInspectorInfo(landList[i]);
      else
        temp = await model.landInspectorInfo(landList[i]);
      info.add(temp);
    }
    allLandInspectorInfo = info;
    setState(() {
      isLoading = false;
    });
    print(info);
  }

  Widget landInspectorList() {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount:
          allLandInspectorInfo == null ? 1 : allLandInspectorInfo.length + 1,
      padding: const EdgeInsets.all(16),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Column(
            children: [
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 1,
                      child: Text('#',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text('Land Inspector Address',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('City',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('Action',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        }

        index -= 1;
        List<dynamic> data = allLandInspectorInfo[index];

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text((index + 1).toString()),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    data[1].toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    data[2].toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    data[5].toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text('Remove'),
                      onPressed: () async {
                        confirmDialog('Are you sure to remove?', context,
                            () async {
                          SmartDialog.showLoading();
                          if (connectedWithMetamask) {
                            await model2.removeLandInspector(data[1]);
                          } else {
                            await model.removeLandInspector(data[1]);
                          }
                          Navigator.pop(context);
                          await getLandInspectorInfo();
                          SmartDialog.dismiss();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget changeContractOwner() {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 600 : double.infinity,
        ),
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Change Contract Owner",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'New Owner Address',
                hintText: 'Enter new contract owner address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an address';
                }
                return null;
              },
              onChanged: (val) {
                newaddress = val;
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          if (connectedWithMetamask) {
                            await model2.changeContractOwner(newaddress);
                          } else {
                            await model.changeContractOwner(newaddress);
                          }
                          showToast("Successfully Changed",
                              context: context, backgroundColor: Colors.green);
                        } catch (e) {
                          print(e);
                          showToast("Something Went Wrong",
                              context: context, backgroundColor: Colors.red);
                        }
                        setState(() {
                          isLoading = false;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Change',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget addLandInspector() {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: width,
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(20),
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
                const Center(
                  child: Text(
                    'Add Land Inspector',
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
                    'Fill the form to register a land inspector',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 16),
                customTextField(
                    'Address', 'Enter Wallet Address', (val) => address = val),
                customTextField('Name', 'Enter Name', (val) => name = val),
                customTextField('Age', 'Enter Age', (val) => age = val,
                    isNumber: true),
                customTextField(
                    'Designation', 'Enter Designation', (val) => desig = val),
                customTextField('City', 'Enter City', (val) => city = val),
                const SizedBox(height: 20),
                Center(
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
                                  await model2.addLandInspector(
                                      address, name, age, desig, city);
                                } else {
                                  await model.addLandInspector(
                                      address, name, age, desig, city);
                                }
                                showToast("Successfully Added",
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
                    child: const Text('Add', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                if (isLoading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget drawer2() {
    return Drawer(
      child: Container(
        width: 260,
        decoration: const BoxDecoration(
          color: Color(0xFF1F2937),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black26, spreadRadius: 2),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.person, size: 80, color: Colors.white),
            const SizedBox(height: 12),
            const Text(
              'Contract Owner',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Colors.white24),
                itemCount: menuItems.length,
                itemBuilder: (BuildContext context, int index) {
                  final isSelected = screen == index;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: Colors.blueGrey.withOpacity(0.4),
                    leading: Icon(
                      menuItems[index].icon,
                      color: isSelected ? Colors.amber : Colors.white70,
                    ),
                    title: Text(
                      menuItems[index].title,
                      style: TextStyle(
                        color: isSelected ? Colors.amber : Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      if (index == 3) {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed('/');
                      }
                      if (index == 1) getLandInspectorInfo();
                      setState(() {
                        screen = index;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
