import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:window_manager/window_manager.dart';

class saying1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hajj Map',
      theme: ThemeData(primarySwatch: Colors.yellow),
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
  Set<Polygon> annulus = {};
  bool alarmPlaying = false;
  bool userDecisionMade = false;
  bool insideMiqatRing = false; // Flag to track if user is inside a miqat ring
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool showMiqatMarkers = false; // Flag to control the visibility of Miqat markers

  // Estimated user location (testing only)
  LatLng userLocation = LatLng(21.875126, 40.464549); // Use the location you estimated

  final List<Map<String, dynamic>> miqatData = [
    {
      "name": "Dhul Hulaifa",
      "closest": LatLng(24.390, 39.535),
      "farthest": LatLng(24.430, 39.550),
    },
    {
      "name": "Juhfa",
      "closest": LatLng(22.700, 39.140),
      "farthest": LatLng(22.730, 39.160),
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
      "name": "Dhat Irq",
      "closest": LatLng(21.910, 40.400),
      "farthest": LatLng(21.950, 40.450),
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
    checkUserLocation(); // Re-check if the user is inside a Miqat zone after updating location
  }

  // Calculate distance between two LatLng points
  double calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // meters
    double lat1 = start.latitude * pi / 180;
    double lon1 = start.longitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double lon2 = end.longitude * pi / 180;

    double dlat = lat2 - lat1;
    double dlon = lon2 - lon1;

    double a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) * sin(dlon / 2) * sin(dlon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;

    return distance;
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

  // Check user location and trigger alarm if inside ring
  void checkUserLocation() {
    if (insideMiqatRing || userDecisionMade) return; // Stop checking if user is inside or has made a decision

    double userDistance = calculateDistance(makkahLocation, userLocation);

    // Loop through all miqats to check if the user is inside any of the rings
    for (var miqat in miqatData) {
      double innerRadius = calculateDistance(makkahLocation, miqat["closest"]);
      double outerRadius = calculateDistance(makkahLocation, miqat["farthest"]);

      if (userDistance >= innerRadius && userDistance <= outerRadius) {
        // Trigger the alarm only if user is inside the miqat ring
        if (!alarmPlaying) {
          startAlarm();  // Start the alarm if inside the ring
        }

        // Show Toast Message indicating user is inside the miqat ring
        Fluttertoast.showToast(
            msg: "You are inside the Miqat ring. Let's start Ihram!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3
        );

        // Stop further checking once the user is inside a miqat ring
        setState(() {
          insideMiqatRing = true;
        });
        showWindowsNotification(context);
        break;  // Exit loop once alarm is triggered
      }
    }

    // Continue checking every 3 seconds until the user makes a decision
    if (!insideMiqatRing && !userDecisionMade) {
      Future.delayed(Duration(seconds: 3), () {
        checkUserLocation();
      });
    }
  }

  // Create circle points for the ring
  List<LatLng> createCircle(LatLng center, double radiusMeters, int points) {
    const double degreeStep = 360 / 72;
    List<LatLng> circlePoints = [];

    for (double angle = 0; angle < 360; angle += degreeStep) {
      double angleRad = angle * pi / 180;
      double latOffset = radiusMeters / 111320 * cos(angleRad);
      double lngOffset =
          radiusMeters / (111320 * cos(center.latitude * pi / 180)) * sin(angleRad);

      circlePoints.add(LatLng(center.latitude + latOffset, center.longitude + lngOffset));
    }

    return circlePoints;
  }

  // Select miqat and draw ring on map
  void _onMiqatSelected(Map<String, dynamic> miqat) {
    LatLng closest = miqat["closest"];
    LatLng farthest = miqat["farthest"];

    double innerRadius = calculateDistance(makkahLocation, closest);
    double outerRadius = calculateDistance(makkahLocation, farthest);

    List<LatLng> outerCircle = createCircle(makkahLocation, outerRadius, 72);
    List<LatLng> innerCircle = createCircle(makkahLocation, innerRadius, 72);

    setState(() {
      selectedMarker = Marker(
        markerId: MarkerId(miqat["name"]),
        position: closest,
        infoWindow: InfoWindow(title: miqat["name"]),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue), // Yellow marker for Makkah
      );

      annulus = {
        Polygon(
          polygonId: PolygonId("${miqat["name"]}_annulus"),
          points: outerCircle,
          holes: [innerCircle], // Cut out inner circle
          fillColor: Colors.blue.withOpacity(0.3), // Only the ring is colored
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      };
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(closest, 9),
    );
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
            polygons: annulus, // Apply annulus (ring) effect
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
                              _onMiqatSelected(miqatData[index]);
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
