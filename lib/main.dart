import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Location fetch karne ke liye
import 'package:firebase_core/firebase_core.dart'; // Firebase init ke liye
import 'package:firebase_database/firebase_database.dart'; // Realtime Data ke liye

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase ko start karna
  runApp(MaterialApp(
    home: SOSHome(),
    debugShowCheckedModeBanner: false,
  ));
}

class SOSHome extends StatelessWidget {
  final database = FirebaseDatabase.instance.ref();

  // SOS Alert Function
  Future<void> sendEmergencyAlert() async {
    try {
      // 1. Location Permission Check
      LocationPermission permission = await Geolocator.requestPermission();
      
      // 2. Get Current Location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      // 3. Send to Firebase (Singapore Server Logic)
      await database.child("emergency_alerts").push().set({
        "lat": position.latitude,
        "long": position.longitude,
        "timestamp": DateTime.now().toIso8601String(),
        "status": "DANGER",
        "device": "Android_Phone"
      });
      
      print("Alert Sent Successfully!");
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("GPS SAVER SOS"),
        backgroundColor: Colors.red[900],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onLongPress: () => sendEmergencyAlert(), // 2 second hold logic
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.redAccent, blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                child: Center(
                  child: Text(
                    "HOLD SOS",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Hold for 2 seconds to alert Police",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
