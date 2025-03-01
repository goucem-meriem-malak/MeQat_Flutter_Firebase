import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meqattest/Settings.dart';
import 'package:window_manager/window_manager.dart';

import 'menu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showPolygons = false; // Toggle between annulus and polygons
  late GoogleMapController mapController;
  final LatLng makkahLocation = LatLng(21.422487, 39.826206);
  int? _selectedSayingIndex; // Track the selected button
  double _currentChildSize = 0.1; // Track the sheet's height
  String _sayingDescription = "";
  final DraggableScrollableController _scrollController = DraggableScrollableController();

  Set<Marker> selectedMarkers = {};
  Marker? selectedMarker;
  Set<Polygon> annulus = {};
  Set<Polygon> polygons = {};
  Set<Polyline> miqatLines = {};
  Set<Polyline> Lines = {};
  bool alarmPlaying = false;
  bool userDecisionMade = false;
  bool insideMiqatRing = false; // Flag to track if user is inside a miqat ring
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool showMiqatMarkers = false; // Flag to control the visibility of Miqat markers

  // Estimated user location (testing only)
  LatLng userLocation = LatLng(21.875126, 40.464549); // Use the location you estimated
  //final LatLng userLocation = LatLng(22.161093, 40.464549);

  void _onSayingPressed(int index, String description) {
    setState(() {
      _selectedSayingIndex = index;
      _sayingDescription = description;
      _currentChildSize = 0.3; // Expand the sheet slightly
    });
    _scrollController.animateTo(
      0.3, // Expand to 30% height
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  final List<Map<String, dynamic>> miqatData = [
    {
      "name": "Dhul Hulaifa",
      "center": LatLng(24.413942807343183, 39.54297293708976),
      "closest": LatLng(24.390, 39.535),
      "farthest": LatLng(24.430, 39.550),
    },
    {
      "name": "Dhat Irq",
      "center": LatLng(21.930072877611384, 40.42552892351149),
      "closest": LatLng(21.910, 40.400),
      "farthest": LatLng(21.950, 40.450),
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
      "name": "Juhfa",
      "center": LatLng(22.71515249938801, 39.14514729649877),
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
      //_getCurrentLocation();
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
  }

  // Calculate distance between two LatLng points


  void showSaying1() {
    resetMap();
    setState(() {
      selectedMarkers.clear();
      annulus.clear();
      showPolygons = false; // Ensure polygons are hidden

      for (var miqat in miqatData) {
        LatLng center = miqat["center"];
        LatLng closest = miqat["closest"];
        LatLng farthest = miqat["farthest"];

        double innerRadius = calculateDistance(makkahLocation, closest);
        double outerRadius = calculateDistance(makkahLocation, farthest);

        List<LatLng> outerCircle = createCircle(makkahLocation, outerRadius, 72);
        List<LatLng> innerCircle = createCircle(makkahLocation, innerRadius, 72);

        annulus.add(Polygon(
          polygonId: PolygonId("${miqat["name"]}_annulus"),
          points: outerCircle,
          holes: [innerCircle],
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ));

        selectedMarkers.add(Marker(
          markerId: MarkerId(miqat["name"]),
          position: center,
          infoWindow: InfoWindow(title: miqat["name"]),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      }

      showMiqatMarkers = true;
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(makkahLocation, 8),
    );
  }
  void showSaying2() {
    resetMap();
    List<LatLng> outerPoints = [
      miqatData[0]["farthest"], miqatData[1]["farthest"], miqatData[2]["farthest"], miqatData[3]["farthest"], miqatData[4]["farthest"], miqatData[0]["farthest"]
    ];
    List<LatLng> innerPoints = [
      miqatData[0]["closest"], miqatData[1]["closest"], miqatData[2]["closest"], miqatData[3]["closest"], miqatData[4]["closest"], miqatData[0]["closest"]
    ];

    setState(() {
      polygons.clear();
      showPolygons = true;

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
  void showSaying3() {
    resetMap();
    setState(() {
      annulus.clear(); // Clear previous annulus sectors
      selectedMarkers.clear(); // Clear previous markers

      for (var miqat in miqatData) {
        LatLng center = miqat["center"];
        double innerRadius = calculateDistance(makkahLocation, miqat["closest"]);
        double outerRadius = calculateDistance(makkahLocation, miqat["farthest"]);

        List<LatLng> outerSector = createOpenSector(makkahLocation, center, outerRadius);
        List<LatLng> innerSector = createOpenSector(makkahLocation, center, innerRadius);

        selectedMarkers.add(Marker(
          markerId: MarkerId(miqat["name"]),
          position: center,
          infoWindow: InfoWindow(title: miqat["name"]),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));

        // Add open sector for each miqat
        annulus.add(Polygon(
          polygonId: PolygonId("${miqat["name"]}_sector"),
          points: [...outerSector, ...innerSector.reversed],
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ));
      }
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(makkahLocation, 8), // Center on Makkah
    );
  }
  void showSaying4() {
    resetMap();
    Set<Polyline> newLines = {};

    for (var miqat in miqatData) {
      LatLng miqatCenter = miqat["center"];
      String miqatName = miqat["name"];

      // 🔴 Direct line from Miqat to Makkah
      newLines.add(Polyline(
        polylineId: PolylineId("direct_$miqatName"),
        color: Colors.red,
        width: 3,
        points: [miqatCenter, makkahLocation],
      ));

      double miqatDistance = _calculateDistance(miqatCenter, makkahLocation);
      double lineThickness = (miqatDistance / 1000).clamp(3, 10).toDouble();

      double dx = makkahLocation.latitude - miqatCenter.latitude;
      double dy = makkahLocation.longitude - miqatCenter.longitude;
      double length = sqrt(dx * dx + dy * dy);

      double normX = dx / length;
      double normY = dy / length;

      double perpX = -normY;
      double perpY = normX;

      double miqatLineLength = (miqatDistance / 200000);

      LatLng miqatLineStart = LatLng(
        miqatCenter.latitude + perpX * miqatLineLength,
        miqatCenter.longitude + perpY * miqatLineLength,
      );
      LatLng miqatLineEnd = LatLng(
        miqatCenter.latitude - perpX * miqatLineLength,
        miqatCenter.longitude - perpY * miqatLineLength,
      );

      // 🔵 Perpendicular Miqat line
      newLines.add(Polyline(
        polylineId: PolylineId("miqatline_$miqatName"),
        color: Colors.blue,
        width: lineThickness.toInt(),
        points: [miqatLineStart, miqatLineEnd],
      ));
    }

    setState(() {
      miqatLines = newLines;
    });

    // 🔍 Move camera to show all Miqats & Makkah
    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(makkahLocation, 6),
    );
  }
  void showSaying5() {
    resetMap();
    Set<Polyline> newLines = {
      // Direct line from User to Makkah
      Polyline(
        polylineId: PolylineId("direct_line"),
        color: Colors.red,
        width: 3,
        points: [userLocation, makkahLocation],
      ),
    };

    for (var miqat in miqatData) {
      LatLng miqatCenter = miqat["center"];
      double miqatDistance = _calculateDistance(miqatCenter, makkahLocation);
      double lineThickness = (miqatDistance / 1000).clamp(3, 10).toDouble();

      double dx = makkahLocation.latitude - miqatCenter.latitude;
      double dy = makkahLocation.longitude - miqatCenter.longitude;
      double length = sqrt(dx * dx + dy * dy);

      double normX = dx / length;
      double normY = dy / length;

      double perpX = -normY;
      double perpY = normX;

      double miqatLineLength = (miqatDistance / 200000);

      LatLng miqatLineStart = LatLng(
        miqatCenter.latitude + perpX * miqatLineLength,
        miqatCenter.longitude + perpY * miqatLineLength,
      );
      LatLng miqatLineEnd = LatLng(
        miqatCenter.latitude - perpX * miqatLineLength,
        miqatCenter.longitude - perpY * miqatLineLength,
      );

      newLines.add(Polyline(
        polylineId: PolylineId("miqatline_${miqat["name"]}"),
        color: Colors.blue,
        width: lineThickness.toInt(),
        points: [miqatLineStart, miqatLineEnd],
      ));
    }

    setState(() {
      miqatLines = newLines;
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(makkahLocation, 6),
    );
  }

  void resetMap() {
    setState(() {
      selectedMarkers.clear();
      annulus.clear();
      polygons.clear();
      miqatLines.clear();
      showPolygons = false;
      showMiqatMarkers = false;
    });
  }


// Check user location and trigger alarm if inside ring
  void checkUserLocationSaying1() {
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
        checkUserLocationSaying1();
      });
    }
  }
  void checkUserLocationSaying2() {
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
  void checkUserLocationSaying3() {
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
        checkUserLocationSaying3();
      });
    }
  }
  void checkUserLocationSaying4() {
    for (var miqat in miqatData) {
      double distance = _calculateDistance(userLocation, miqat["center"]);
      if (distance <= 1000) {
        startAlarm();
        break;
      }
    }
  }
  void checkUserLocationSaying5() {
    double userDistanceToMiqatLine = _calculateDistance(userLocation, miqatLines.first.points.first);
    if (userDistanceToMiqatLine <= 1000) {
      showWindowsNotification(context);
      startAlarm();
    }
  }


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
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000;
    double lat1 = point1.latitude * pi / 180;
    double lon1 = point1.longitude * pi / 180;
    double lat2 = point2.latitude * pi / 180;
    double lon2 = point2.longitude * pi / 180;

    double dlat = lat2 - lat1;
    double dlon = lon2 - lon1;

    double a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) *
            sin(dlon / 2) * sin(dlon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
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
    LatLng closest = miqat["closest"];
    LatLng center = miqat["center"];
    LatLng farthest = miqat["farthest"];

    double innerRadius = calculateDistance(makkahLocation, closest);
    double outerRadius = calculateDistance(makkahLocation, farthest);

    List<LatLng> outerCircle = createCircle(makkahLocation, outerRadius, 72);
    List<LatLng> innerCircle = createCircle(makkahLocation, innerRadius, 72);

    setState(() {
      selectedMarker = Marker(
        markerId: MarkerId(miqat["name"]),
        position: center,
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
          /// **Google Map as Background**
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
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
              ),
              Marker(
                markerId: MarkerId("userLocation"),
                position: userLocation,
                infoWindow: InfoWindow(title: "Your Location"),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
              ...selectedMarkers, // ✅ Now displays all Miqat markers
            },
            polygons: {
              ...annulus, // ✅ Displays annulus (Saying 1 & 3)
              ...polygons, // ✅ Displays polygons (Saying 2)
            },
            polylines: miqatLines, // ✅ Displays polylines (Saying 4 & 5)
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
          ),



          /// **Draggable Sheet with Sayings**
          DraggableScrollableSheet(
            controller: _scrollController, // Attach controller
            initialChildSize: 0.1,
            minChildSize: 0.1,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    /// **Drag Handle**
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    /// **Horizontal Saying Buttons**
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          5,
                              (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                _selectedSayingIndex == index ? Colors.orange : Colors.black,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              onPressed: () {
                                if (index == 0) {
                                  checkUserLocationSaying1();
                                  showSaying1();
                                  _onSayingPressed(index, "Is not approved by any madhhab");
                                } else if (index == 1) {
                                  checkUserLocationSaying2();
                                  showSaying2();
                                  _onSayingPressed(index, "Is not approved by any madhhab");
                                } else if (index == 2) {
                                  checkUserLocationSaying3();
                                  showSaying3();
                                  _onSayingPressed(index, "Saying 3 is approved by all 4 madhhabs");
                                } else if (index == 3) {
                                  checkUserLocationSaying4();
                                  showSaying4();
                                  _onSayingPressed(index, "Description for Saying 4");
                                } else if (index == 4) {
                                  checkUserLocationSaying5();
                                  showSaying5();
                                  _onSayingPressed(index, "Only approved by madhhab Hanbali");
                                }
                              },
                              child: Text('Saying ${index + 1}',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// **Show Description Instead of Grid**
                    if (_selectedSayingIndex != null)
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController, // Keep it draggable
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _sayingDescription,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 56, // Adjust the height to make it thinner
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(), // Optional: Adds a slight curve
          notchMargin: 6.0, // Optional: Space for floating action button
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.menu),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MenuPage()),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: Colors.orange, // Selected icon in orange
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () {},
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
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
