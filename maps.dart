import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'database.dart';
import 'mainPage.dart';
import 'profile.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "dart:ffi";
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

class MapsPage extends StatefulWidget {
  final user;
  MapsPage(this.user);

  Location location = new Location();

  getPermissions() async {
    var status = await Permission.location.request();
  }

  void uploadLocation() async {
    LocationData position = await location.getLocation();
    uploadPosition(position.latitude, position.longitude);
  }

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  TextEditingController caption = new TextEditingController();

  Set<Marker> _markers = {};
  Location location = new Location();

  getPermissions() async {
    var status = await Permission.location.request();
  }

  void uploadLocation() async {
    LocationData position = await location.getLocation();
    uploadPosition(position.latitude, position.longitude);
  }

  void initState() {
    super.initState;

    if (widget.user.uid != "WFm77q5qNSc8J6O9NmEOGzh5TAe2") {
      uploadLocation();
    }
    returnMarkers.listen((event) {
      event.docs.forEach((element) async {
        element["Allow"] == true
            ? _markers.add(Marker(
                markerId: MarkerId(element["UID"]),
                position:
                    LatLng(element["Position"][0], element["Position"][1]),
                icon: BitmapDescriptor.fromBytes(await getImage(element[
                            "ImageURL"] !=
                        "error"
                    ? element["ImageURL"]
                    : "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png")),
                infoWindow: InfoWindow(title: element["username"])))
            : null;
        setState(() {});
      });
    });
  }

  _onMapCreated(GoogleMapController controller) {
    uploadLocation();
    setState(() {});
  }

  getImage(imageUrl) async {
    final int targetWidth = 100;
    final File markerImageFile =
        await DefaultCacheManager().getSingleFile(imageUrl);
    final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
    final Codec markerImageCodec = await instantiateImageCodec(
      markerImageBytes,
      targetWidth: targetWidth,
    );
    final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
    final dynamic byteData = await frameInfo.image.toByteData(
      format: ImageByteFormat.png,
    );
    final Uint8List resizedMarkerImageBytes = byteData.buffer.asUint8List();
    return resizedMarkerImageBytes;
  }

  Stream<QuerySnapshot> get returnMarkers {
    return FirebaseFirestore.instance.collection("users").snapshots();
  }

  Future<bool> getAllow() async {
    DocumentSnapshot allow = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.user.uid)
        .get();
    print(allow["Allow"]);
    return allow["Allow"];
  }

  @override
  Widget build(BuildContext context) {
    uploadLocation();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          actions: [
            SizedBox(
              width: 40,
            )
          ],
          leading: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: IconButton(
                onPressed: () => {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.leftToRightWithFade,
                              child: MainPage(widget.user),
                              duration: Duration(milliseconds: 550)))
                    },
                icon: Icon(Icons.arrow_back, size: 25)),
          ),
          backgroundColor: Color.fromRGBO(0, 158, 149, 2),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              Text("Elba", style: TextStyle(fontSize: 25, color: Colors.white)),
              Text("Share",
                  style: TextStyle(
                      fontSize: 25,
                      color: Color.fromRGBO(255, 147, 147, 2),
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        body: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(widget.user.uid)
                .get(),
            builder: (BuildContext context, AsyncSnapshot data) {
              if (data.hasData) {
                var allow = data.requireData;
                return allow["Allow"] == true
                    ? GoogleMap(
                        mapType: MapType.hybrid,
                        onMapCreated: _onMapCreated,
                        markers: _markers,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(42.7791592, 10.2824565), zoom: 11))
                    : Center(
                        child: Text("Non hai attivato la posizione"),
                      );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }
}
