import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
import '../models/doctor_model.dart';

class MarkerFactory {
  // Singleton pattern
  static final MarkerFactory _instance = MarkerFactory._internal();
  factory MarkerFactory() => _instance;
  MarkerFactory._internal();

  // Cache for custom markers to avoid re-downloading/processing
  final Map<String, BitmapDescriptor> _markerCache = {};

  /// Create a marker for the user's location
  Marker createUserMarker(LatLng position) {
    return Marker(
      markerId: const MarkerId('user_location'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(
        title: 'Your Location',
        snippet: 'You are here',
      ),
    );
  }

  /// Create a marker for a doctor (Async with Image)
  Future<Marker> createCustomDoctorMarker({
    required Doctor doctor,
    required double distanceKm,
    required VoidCallback onTap,
  }) async {
    LatLng position;
    if (doctor.latitude != null && doctor.longitude != null) {
      position = LatLng(doctor.latitude!, doctor.longitude!);
    } else {
      position = const LatLng(0, 0);
    }

    BitmapDescriptor icon;

    // Check cache first
    if (_markerCache.containsKey(doctor.id)) {
      icon = _markerCache[doctor.id]!;
    } else {
      try {
        // Fallback or Load Image
        // Use default if image is empty or invalid
        if (doctor.image.isEmpty || doctor.image.contains('assets/')) {
          icon = await _createCustomMarkerBitmap(
            null, // Null means use default icon
            isAvailable: doctor.isAvailable,
          );
        } else {
          icon = await _createCustomMarkerBitmap(
            doctor.image,
            isAvailable: doctor.isAvailable,
          );
        }

        // Save to cache
        _markerCache[doctor.id] = icon;
      } catch (e) {
        debugPrint('❌ Error creating marker for ${doctor.fullName}: $e');
        // Fallback to default
        icon = BitmapDescriptor.defaultMarkerWithHue(
          doctor.isAvailable
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueRed,
        );
      }
    }

    return Marker(
      markerId: MarkerId(doctor.id),
      position: position,
      infoWindow: InfoWindow(
        title: doctor.fullName,
        snippet:
            '${doctor.specialty} - ${distanceKm.toStringAsFixed(1)} km away',
      ),
      icon: icon,
      onTap: onTap,
    );
  }

  /// Helper: Create Circle Bitmap from URL or Default
  Future<BitmapDescriptor> _createCustomMarkerBitmap(
    String? imageUrl, {
    bool isAvailable = true,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final int size = 150; // Size of the marker
    final double radius = size / 2.0;

    // Paints
    final Paint borderPaint = Paint()
      ..color = isAvailable ? Colors.green : Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

    final Paint fillPaint = Paint()..color = Colors.white;

    // Draw Shadow
    canvas.drawCircle(Offset(radius, radius + 5), radius, shadowPaint);

    // Draw Background
    canvas.drawCircle(Offset(radius, radius), radius, fillPaint);

    // Draw Image
    if (imageUrl != null) {
      try {
        final http.Response response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;
          final ui.Codec codec = await ui.instantiateImageCodec(
            bytes,
            targetWidth: size,
            targetHeight: size,
          );
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          final ui.Image image = frameInfo.image;

          // Create circle clip path
          Path circlePath = Path()
            ..addOval(
              Rect.fromCircle(
                center: Offset(radius, radius),
                radius: radius - 5,
              ),
            );

          canvas.save();
          canvas.clipPath(circlePath);
          canvas.drawImage(image, Offset.zero, Paint());
          canvas.restore();
        }
      } catch (e) {
        debugPrint('Failed to load marker image: $e');
        // Fall through to draw border only
      }
    } else {
      // Draw initials or default icon if no image
      // For simplicity, just white circle with colored border
    }

    // Draw Border
    canvas.drawCircle(Offset(radius, radius), radius - 5, borderPaint);

    // Convert to Bitmap
    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
      size,
      size + 10,
    ); // +10 for shadow
    final ByteData? byteData = await markerAsImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  /// Create a generic marker for selection
  Marker createSelectedMarker(LatLng position) {
    return Marker(
      markerId: const MarkerId('selected'),
      position: position,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
  }
}
