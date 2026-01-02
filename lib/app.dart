// import 'package:docmobi/screens/patient/home/patient_home_screen.dart';
import 'package:docmobi/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Docambi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), 
      // home: const PatientHomeScreen(), 
    );
  }
}