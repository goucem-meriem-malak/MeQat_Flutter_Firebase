import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

import 'package:window_manager/window_manager.dart';

class saying5 extends StatelessWidget {
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
  LatLng userLocation = LatLng(21.875126, 40.464549);
  Set<Polyline> miqatLines = {};
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  final List<Map<String, dynamic>> miqatData = [
    {
      "name": "Dhul Hulaifa",
      "center": LatLng(24.413942807343183, 39.54297293708976),
    },
    {
      "name": "Juhfa",
      "center": LatLng(22.71515249938801, 39.14514729649877),
    },
    {
      "name": "Qarn al-Manazil",
      "center": LatLng(21.63320606975049, 40.42677866397942),
    },
    {
      "name": "Yalamlam",
      "center": LatLng(20.518564356141052, 39.870803989418974),
    },
    {
      "name": "Dhat Irq",
      "center": LatLng(21.930072877611384, 40.42552892351149),
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
      drawDirectLine();
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
    checkUserLocation(userLocation); // Re-check if the user is inside a Miqat zone after updating location
  }

  void drawDirectLine() {
    Set<Polyline> newLines = {
      Polyline(
        polylineId: PolylineId("direct_line"),
        color: Colors.red,
        width: 3,
        points: [userLocation, makkahLocation],
      ),
    };

    Map<String, dynamic> closestMiqat = miqatData.reduce((a, b) =>
    _calculateDistance(userLocation, a["center"]) <
        _calculateDistance(userLocation, b["center"]) ?
    a :
    b);

    LatLng miqatCenter = closestMiqat["center"];
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
      polylineId: PolylineId("miqatline_${closestMiqat["name"]}"),
      color: Colors.blue,
      width: lineThickness.toInt(),
      points: [miqatLineStart, miqatLineEnd],
    ));

    setState(() {
      miqatLines = newLines;
    });
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

  void checkUserLocation(LatLng userPos) {
    double userDistanceToMiqatLine = _calculateDistance(userPos, miqatLines.first.points.first);
    if (userDistanceToMiqatLine <= 1000) {
      showWindowsNotification(context);
      startAlarm();
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
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: makkahLocation,
          zoom: 6,
        ),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        polylines: miqatLines,
        markers: {
          Marker(
            markerId: MarkerId("user"),
            position: userLocation,
            infoWindow: InfoWindow(title: "Your location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
          Marker(
            markerId: MarkerId("makkah"),
            position: makkahLocation,
            infoWindow: InfoWindow(title: "Makkah"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          ),
          ...miqatData.map(
                (miqat) => Marker(
              markerId: MarkerId(miqat["name"]),
              position: miqat["center"],
              infoWindow: InfoWindow(title: miqat["name"]),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          ),
        },
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
