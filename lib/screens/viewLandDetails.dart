import 'package:flutter/material.dart';
import 'package:land_registration/constant/constants.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import '../constant/utils.dart';

class ViewLandDetails extends StatefulWidget {
  final String allLatitude;
  final String allLongitude;
  final LandInfo landinfo;

  const ViewLandDetails({
    Key? key,
    required this.allLatitude,
    required this.allLongitude,
    required this.landinfo,
  }) : super(key: key);

  @override
  _ViewLandDetailsState createState() => _ViewLandDetailsState();
}

class _ViewLandDetailsState extends State<ViewLandDetails> {
  late MapboxMapController mapController;

  void _onMapCreated(MapboxMapController controller) async {
    mapController = controller;

    List<double> latitudes =
        widget.allLatitude.split(',').map((e) => double.parse(e)).toList();
    List<double> longitudes =
        widget.allLongitude.split(',').map((e) => double.parse(e)).toList();

    await Future.delayed(const Duration(seconds: 3));
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      zoom: 15.0,
      target: LatLng(latitudes[1], longitudes[0]),
    )));

    for (int i = 0; i < latitudes.length; i++) {
      mapController.addCircle(CircleOptions(
        geometry: LatLng(latitudes[i], longitudes[i]),
        circleRadius: 5,
        circleColor: "#ff0000",
        draggable: false,
      ));
    }

    mapController.addFill(
      FillOptions(
        fillColor: "#2596be",
        fillOutlineColor: "#2596be",
        geometry: [
          List.generate(latitudes.length,
              (index) => LatLng(latitudes[index], longitudes[index]))
        ],
      ),
    );
  }

  Widget _buildDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 250,
              child: Text(
                "$title:",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              )),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Land Details'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// // //Map Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: SizedBox(
                    height: 500,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: MapboxMap(
                        accessToken: mapBoxApiKey,
                        styleString:
                            "mapbox://styles/saurabhmw/cky4ce7f61b2414nuh9ng177k",
                        initialCameraPosition: const CameraPosition(
                          zoom: 3.0,
                          target: LatLng(19.663280, 75.300293),
                        ),
                        compassEnabled: false,
                        onMapCreated: _onMapCreated,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                /// // //Title
                const Center(
                  child: Text('Details',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent)),
                ),
                const SizedBox(height: 20),

                /// // //Details Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDetail("Area", widget.landinfo.area),
                        _buildDetail(
                            "Owner Address", widget.landinfo.ownerAddress),
                        _buildDetail(
                            "Land Address", widget.landinfo.landAddress),
                        _buildDetail("Price", widget.landinfo.landPrice),
                        _buildDetail("Survey Number",
                            widget.landinfo.physicalSurveyNumber),
                        _buildDetail(
                            "Property ID", widget.landinfo.propertyPID),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                  width: 150,
                                  child: Text("Document:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18))),
                              TextButton.icon(
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text("View Document",
                                    style: TextStyle(fontSize: 18)),
                                onPressed: () {
                                  launchUrl(widget.landinfo.document);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


//GoogleMap(
// // //                  key: _key,
// // //                  markers: {
// // //                    Marker(GeoCoord(17.48801845587808, 75.28015598816665)),
// // //                    Marker(GeoCoord(17.488100319437635, 75.28213009400162)),
// // //                    Marker(GeoCoord(17.487384012042043, 75.28214082283768)),
// // //                    Marker(GeoCoord(17.487256099710205, 75.28020963234695))
// // //                  },
// // //                  initialZoom: 18,
// // //                  initialPosition: GeoCoord(
// // //                      (17.48801845587808 +
// // //                              17.488100319437635 +
// // //                              17.487384012042043 +
// // //                              17.487256099710205) /
// // //                          4,
// // //                      (75.28015598816665 +
// // //                              75.28213009400162 +
// // //                              75.28214082283768 +
// // //                              75.28020963234695) /
// // //                          4),
// // //                  mapType: _mapStyle,
// // //                  interactive: true,
// // //                  mobilePreferences: const MobileMapPreferences(
// // //                    trafficEnabled: true,
// // //                    zoomControlsEnabled: false,
// // //                  ),
// // //                  webPreferences: WebMapPreferences(
// // //                    fullscreenControl: true,
// // //                    zoomControl: true,
// // //                  ),
// // //                )
