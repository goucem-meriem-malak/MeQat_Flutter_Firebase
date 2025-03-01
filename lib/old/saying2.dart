import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:window_manager/window_manager.dart';

class saying2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hajj Map',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HajjMapPage(),
    );
  }
}

class HajjMapPage extends StatefulWidget {
  @override
  _HajjMapPageState createState() => _HajjMapPageState();
}

class _HajjMapPageState extends State<HajjMapPage> {
  late GoogleMapController mapController;
  final LatLng makkahLocation = LatLng(21.422487, 39.826206);

  Marker? selectedMarker;
  Set<Polygon> polygons = {};
  bool alarmPlaying = false;
  bool userDecisionMade = false;
  bool insideMiqatRing = false; // Flag to track if user is inside a miqat ring
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool showMiqatMarkers = false; // Flag to control the visibility of Miqat markers

  // Estimated user location (testing only)
  LatLng userLocation = LatLng(21.422487, 39.826206); // Default near Makkah, updated dynamically

  final List<Map<String, dynamic>> miqatData = [
    {
      "name": "Dhul Hulaifa",
      "closest": LatLng(24.390, 39.535),
      "farthest": LatLng(24.430, 39.550),
    },
    {
      "name": "Dhat Irq",
      "closest": LatLng(21.910, 40.400),
      "farthest": LatLng(21.950, 40.450),
    },
    {
      "name": "Qarn al-Manazil",
      "closest": LatLng(21.610, 40.410),
      "farthest": LatLng(21.650, 40.440),
    },
    {
      "name": "Yalamlam",
      "closest": LatLng(20.500, 39.850),
      "farthest": LatLng(20.540, 39.890),
    },
    {
      "name": "Juhfa",
      "closest": LatLng(22.700, 39.140),
      "farthest": LatLng(22.730, 39.160),
    },
  ];


  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(Duration.zero, () {
      _getCurrentLocation();
      createMiqatPolygons();
    });
  }
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled. Please enable them.')),
      );
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });

    // Now that the user's location is updated, you can proceed with any further logic,
    // like creating Miqat polygons or checking the user location against Miqat zones
    checkUserInsideMiqatZone(); // Re-check if the user is inside a Miqat zone after updating location
  }

  void createMiqatPolygons() {
    List<LatLng> outerPoints = [
      miqatData[0]["farthest"], miqatData[1]["farthest"], miqatData[2]["farthest"], miqatData[3]["farthest"], miqatData[4]["farthest"], miqatData[0]["farthest"]
    ];
    List<LatLng> innerPoints = [
      miqatData[0]["closest"], miqatData[1]["closest"], miqatData[2]["closest"], miqatData[3]["closest"], miqatData[4]["closest"], miqatData[0]["closest"]
    ];

    setState(() {
      polygons = {
        Polygon(
          polygonId: PolygonId("miqat_zone"),
          points: [...outerPoints, ...innerPoints.reversed],
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
        Polygon(
          polygonId: PolygonId("miqat_inner"),
          points: innerPoints,
          fillColor: Colors.transparent,
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
        Polygon(
          polygonId: PolygonId("miqat_outer"),
          points: outerPoints,
          fillColor: Colors.transparent,
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      };
    });
  }

  bool isPointInsidePolygon(LatLng point, List<LatLng> polygon) {
    int i, j;
    bool inside = false;
    for (int i = 0, j = polygon.length - 1; i < polygon.length; j = i, i++) {
      // Check if point is inside the polygon
      if (((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude)) &&
          (point.longitude < (polygon[j].longitude - polygon[i].longitude) * (point.latitude - polygon[i].latitude) /
              (polygon[j].latitude - polygon[i].latitude) +
              polygon[i].longitude)) {
        inside = !inside;
      }
    }
    return inside;
  }


  void checkUserInsideMiqatZone() {
    List<LatLng> outerPoints = miqatData.map((e) => e["farthest"] as LatLng).toList();
    List<LatLng> innerPoints = miqatData.map((e) => e["closest"] as LatLng).toList();

    // Check if the user is inside the outer polygon but not inside the inner polygon.
    bool insideOuter = isPointInsidePolygon(userLocation, outerPoints);
    bool insideInner = isPointInsidePolygon(userLocation, innerPoints);
    bool insideZone = insideOuter && !insideInner;

    if (insideZone && !alarmPlaying) {
      startAlarm();
      showWindowsNotification(context);
    }
  }

  void startAlarm() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Set infinite looping
      await _audioPlayer.play(AssetSource('alarm2.mp3'));
      setState(() => _isPlaying = true);
    } catch (e) {
      print("Error playing alarm: $e");
    }
  }

  Future<void> _stopAlarm() async {
    await _audioPlayer.stop();
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: makkahLocation,
              zoom: 6,
            ),
            markers: {
              if (selectedMarker != null) selectedMarker!,
              Marker(
                markerId: MarkerId("userlocation"),
                position: userLocation,
                infoWindow: InfoWindow(title: "Your Location"),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Yellow marker for Makkah
              ),
              Marker(
                markerId: MarkerId("makkah"),
                position: makkahLocation,
                infoWindow: InfoWindow(title: "Makkah"),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow), // Yellow marker for Makkah
              ),
              Marker(
                markerId: MarkerId("userLocation"),
                position: userLocation,
                infoWindow: InfoWindow(title: "Your Location"),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Red marker for User location
              ),
              if (showMiqatMarkers) // Show Miqat markers only if the flag is true
                ...miqatData.map((miqat) {
                  return Marker(
                    markerId: MarkerId(miqat["name"]),
                    position: miqat["closest"],
                    infoWindow: InfoWindow(title: miqat["name"]),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Blue marker for Miqats
                  );
                }).toSet(),
            },
            polygons: polygons,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.1,  // Reduced initial size for better drag experience
            minChildSize: 0.1,  // Reduced min size to make it easier to drag
            maxChildSize: 0.5,  // Increased max size slightly for more room
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Color(0xFF989898), // Updated color
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                ),
                child: Column(
                  children: [
                    // Black handle on top
                    Container(
                      height: 6,
                      width: 40,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: miqatData.length + 1, // Add 1 for the toggle button
                        itemBuilder: (context, index) {
                          if (index == miqatData.length) {
                            // Toggle Button to show/hide Miqat markers
                            return ListTile(
                              title: Text(showMiqatMarkers ? "Hide Miqat Markers" : "Show Miqat Markers"),
                              onTap: () {
                                setState(() {
                                  showMiqatMarkers = !showMiqatMarkers; // Toggle the visibility
                                });
                              },
                            );
                          }
                          return ListTile(
                            title: Text(miqatData[index]["name"]),
                            onTap: () {
                              // Set the selected marker for the clicked Miqat
                              setState(() {
                                selectedMarker = Marker(
                                  markerId: MarkerId(miqatData[index]["name"]),
                                  position: miqatData[index]["closest"],
                                  infoWindow: InfoWindow(title: miqatData[index]["name"]),
                                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Blue marker for Miqat
                                );
                                // Move the camera to the selected marker
                                mapController.animateCamera(
                                  CameraUpdate.newLatLng(miqatData[index]["closest"]),
                                );
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  void showWindowsNotification(BuildContext context) {
    windowManager.show(); // Ensure the window is visible

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Miqat Alert"),
          content: Text("You are inside the Miqat ring. Do you want to start Ihram?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                debugPrint("Yes button clicked");
                _stopAlarm();
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                debugPrint("Skip button clicked");
                _stopAlarm();
              },
              child: Text("Skip"),
            ),
          ],
        );
      },
    );
  }
}