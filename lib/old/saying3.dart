import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:window_manager/window_manager.dart';

class saying3 extends StatelessWidget {
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
  Set<Polygon> annulus = {};
  bool alarmPlaying = false;
  bool userDecisionMade = false;
  bool insideMiqatRing = false; // Flag to track if user is inside a miqat ring
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool showMiqatMarkers = false; // Flag to control the visibility of Miqat markers

  // Estimated user location (testing only)
  LatLng userLocation = LatLng(21.875126, 40.464549); // Use the location you estimated
  //final LatLng userLocation = LatLng(22.161093, 40.464549);

  final List<Map<String, dynamic>> miqatData = [
    {
      "name": "Dhul Hulaifa",
      "center": LatLng(24.413942807343183, 39.54297293708976),
      "closest": LatLng(24.390, 39.535),
      "farthest": LatLng(24.430, 39.550),
    },
    {
      "name": "Juhfa",
      "center": LatLng(22.71515249938801, 39.14514729649877),
      "closest": LatLng(22.700, 39.140),
      "farthest": LatLng(22.730, 39.160),
    },
    {
      "name": "Qarn al-Manazil",
      "center": LatLng(21.63320606975049, 40.42677866397942),
      "closest": LatLng(21.610, 40.410),
      "farthest": LatLng(21.650, 40.440),
    },
    {
      "name": "Yalamlam",
      "center": LatLng(20.518564356141052, 39.870803989418974),
      "closest": LatLng(20.500, 39.850),
      "farthest": LatLng(20.540, 39.890),
    },
    {
      "name": "Dhat Irq",
      "center": LatLng(21.930072877611384, 40.42552892351149),
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

    for (var miqat in miqatData) {
      double innerRadius = calculateDistance(makkahLocation, miqat["closest"]);
      double outerRadius = calculateDistance(makkahLocation, miqat["farthest"]);

      // Check if user is inside the ring
      if (userDistance >= innerRadius && userDistance <= outerRadius) {
        // Calculate the user's bearing from Makkah
        double userBearing = calculateBearing(makkahLocation, userLocation);
        double miqatBearing = calculateBearing(makkahLocation, miqat["closest"]);

        // Define the allowed range (±60 degrees around miqatBearing)
        double minAngle = (miqatBearing - 60) % 360;
        double maxAngle = (miqatBearing + 60) % 360;

        // Check if userBearing is within the 120-degree range
        bool inSector = isBearingInRange(userBearing, minAngle, maxAngle);

        if (inSector) {
          if (!alarmPlaying) {
            startAlarm();  // Start the alarm if inside the ring and sector
          }

          Fluttertoast.showToast(
              msg: "You are inside the Miqat ring and in the Ihram sector!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 3
          );

          setState(() {
            insideMiqatRing = true;
          });

          showWindowsNotification(context);
          break;  // Stop checking after finding a valid miqat
        }
      }
    }

    // Continue checking every 3 seconds
    if (!insideMiqatRing && !userDecisionMade) {
      Future.delayed(Duration(seconds: 3), () {
        checkUserLocation();
      });
    }
  }

// Helper function to check if a bearing is in a given range
  bool isBearingInRange(double bearing, double min, double max) {
    if (min <= max) {
      return bearing >= min && bearing <= max;
    } else {
      return bearing >= min || bearing <= max; // Handles wrap-around at 360 degrees
    }
  }


  // Create 120-degree sector around Makkah, without connecting the ends
  List<LatLng> createOpenSector(LatLng center, LatLng miqat, double radiusMeters) {
    const double sectorAngle = 60; // 60 degrees on each side of the miqat
    List<LatLng> sectorPoints = [];

    // Calculate bearing between Makkah and Miqat
    double bearing = calculateBearing(center, miqat);

    // Create points for the open sector, extending 60 degrees to the left and 60 degrees to the right
    for (double angle = -sectorAngle; angle <= sectorAngle; angle += 5) {
      double angleRad = (bearing + angle) * pi / 180;
      double latOffset = radiusMeters / 111320 * cos(angleRad);
      double lngOffset =
          radiusMeters / (111320 * cos(center.latitude * pi / 180)) * sin(angleRad);

      sectorPoints.add(LatLng(center.latitude + latOffset, center.longitude + lngOffset));
    }

    // Don't close the loop, ensure no connection between start and end points
    return sectorPoints;
  }


  // Calculate the bearing between two points
  double calculateBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * pi / 180;
    double lon1 = start.longitude * pi / 180;
    double lat2 = end.latitude * pi / 180;
    double lon2 = end.longitude * pi / 180;

    double dlon = lon2 - lon1;
    double y = sin(dlon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dlon);
    double bearing = atan2(y, x);

    return (bearing * 180 / pi + 360) % 360;
  }

  // Select miqat and draw ring on map
  void _onMiqatSelected(Map<String, dynamic> miqat) {
    LatLng center = makkahLocation;  // Makkah remains the center
    LatLng miqatCenter = miqat["center"];

    double innerRadius = calculateDistance(makkahLocation, miqat["closest"]);
    double outerRadius = calculateDistance(makkahLocation, miqat["farthest"]);

    List<LatLng> outerSector = createOpenSector(center, miqatCenter, outerRadius);
    List<LatLng> innerSector = createOpenSector(center, miqatCenter, innerRadius);

    setState(() {
      selectedMarker = Marker(
        markerId: MarkerId(miqat["name"]),
        position: miqatCenter,
        infoWindow: InfoWindow(title: miqat["name"]),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );

      annulus = {
        Polygon(
          polygonId: PolygonId("${miqat["name"]}_annulus"),
          points: [
            ...outerSector,  // Draw the outer sector normally
            ...innerSector.reversed, // Connect opposite sector end
          ],
          holes: [],
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      };
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(miqatCenter, 9),
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
