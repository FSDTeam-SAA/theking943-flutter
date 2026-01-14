import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../providers/user_provider.dart';

class DoctorPersonalInfoScreen extends StatefulWidget {
  const DoctorPersonalInfoScreen({super.key});

  @override
  State<DoctorPersonalInfoScreen> createState() => _DoctorPersonalInfoScreenState();
}

class _DoctorPersonalInfoScreenState extends State<DoctorPersonalInfoScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;
  bool _hasChanges = false;
  
  // Location variables
  double? _latitude;
  double? _longitude;
  String? _locationAddress;

  final ImagePicker _picker = ImagePicker();

  // Specialty options
  final List<String> _specialtyOptions = [
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Orthopedic',
    'Pediatrician',
    'Psychiatrist',
    'General Physician',
    'ENT Specialist',
    'Gynecologist',
    'Ophthalmologist',
    'Dentist',
    'Urologist',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Track changes
    _bioController.addListener(() => setState(() => _hasChanges = true));
    _nameController.addListener(() => setState(() => _hasChanges = true));
    _specialtyController.addListener(() => setState(() => _hasChanges = true));
    _degreeController.addListener(() => setState(() => _hasChanges = true));
    _addressController.addListener(() => setState(() => _hasChanges = true));
    _phoneController.addListener(() => setState(() => _hasChanges = true));
  }

  void _loadUserData() {
    final user = context.read<UserProvider>().user;
    if (user != null) {
      _nameController.text = user.fullName;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      _bioController.text = user.bio ?? '';
      _specialtyController.text = user.specialty ?? '';
      _degreeController.text = user.medicalLicenseNumber ?? '';
      _currentImageUrl = user.profileImage;
      
      // Load location if available
      // _latitude = user.latitude;
      // _longitude = user.longitude;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _hasChanges = true;
        });
        print('📸 Image selected: ${image.path}');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  void _showSpecialtyPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Specialty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2C49),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: _specialtyOptions.length,
                itemBuilder: (context, index) {
                  final specialty = _specialtyOptions[index];
                  final isSelected = _specialtyController.text == specialty;
                  
                  return ListTile(
                    title: Text(specialty),
                    trailing: isSelected 
                        ? const Icon(Icons.check, color: Color(0xFF1664CD))
                        : null,
                    onTap: () {
                      setState(() {
                        _specialtyController.text = specialty;
                        _hasChanges = true;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _locationAddress = result['address'];
        _addressController.text = _locationAddress ?? '';
        _hasChanges = true;
      });
    }
  }

Future<void> _saveProfile() async {
  if (!_hasChanges) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No changes to save')),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final userProvider = context.read<UserProvider>();

    final success = await userProvider.updateUserProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      bio: _bioController.text.trim(),
      specialty: _specialtyController.text.trim(),
      profileImage: _selectedImage,
      latitude: _latitude,        // ✅ ADD THIS
      longitude: _longitude,      // ✅ ADD THIS
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _hasChanges = false;
          _selectedImage = null;
          _currentImageUrl = userProvider.user?.profileImage;
        });
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${userProvider.error ?? "Update failed"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2C49)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          children: [
            Text(
              'Personal Info',
              style: TextStyle(
                color: Color(0xFF1B2C49),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Edit Your Profile',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F0FF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Profile Picture',
                          style: TextStyle(
                            color: Color(0xFF1B2C49),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                      ? NetworkImage(_currentImageUrl!)
                                      : const AssetImage('assets/images/doctor_booking.png')
                                          as ImageProvider),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 18,
                                  color: Color(0xFF1B2C49),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Tap to Change your Profile Picture',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Bio Section
                const Text(
                  'Add Bio',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2C49),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F0FF),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFB3CEFF)),
                  ),
                  child: TextField(
                    controller: _bioController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF1B2C49)),
                    decoration: const InputDecoration(
                      hintText: 'Tell us about yourself...',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Info Fields
                _buildInfoCard(
                  icon: Icons.person_outline, 
                  controller: _nameController,
                  hint: 'Enter your full name',
                ),
                _buildSpecialtyCard(),
                _buildInfoCard(
                  icon: Icons.school_outlined, 
                  controller: _degreeController,
                  hint: 'MBBS, MD, etc.',
                ),
                _buildInfoCard(
                  icon: Icons.email_outlined, 
                  controller: _emailController, 
                  enabled: false,
                  hint: 'Email cannot be changed',
                ),
                
                // Location Card with Map Icon
                _buildLocationCard(),
                
                _buildInfoCard(
                  icon: Icons.phone_outlined, 
                  controller: _phoneController,
                  hint: 'Contact number',
                ),

                const SizedBox(height: 30),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1664CD),
                      disabledBackgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Update Profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.location_on_outlined, color: Color(0xFF1664CD), size: 22),
        ),
        title: TextField(
          controller: _addressController,
          readOnly: true,
          onTap: _openLocationPicker,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1B2C49),
            fontWeight: FontWeight.w500,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Set your clinic location',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.my_location,
            color: Color(0xFF1664CD),
            size: 24,
          ),
          onPressed: _openLocationPicker,
        ),
      ),
    );
  }

  Widget _buildSpecialtyCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person_search_outlined, color: Color(0xFF1B2C49), size: 22),
        ),
        title: TextField(
          controller: _specialtyController,
          readOnly: true,
          onTap: _showSpecialtyPicker,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF1B2C49),
            fontWeight: FontWeight.w500,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Select your specialty',
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_drop_down,
          color: Color(0xFF1B2C49),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required TextEditingController controller,
    bool enabled = true,
    String? hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F0FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1B2C49), size: 22),
        ),
        title: TextField(
          controller: controller,
          enabled: enabled,
          style: TextStyle(
            fontSize: 16,
            color: enabled ? const Color(0xFF1B2C49) : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        trailing: Icon(
          enabled ? Icons.edit_outlined : Icons.lock_outline,
          color: enabled ? const Color(0xFF1B2C49) : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _specialtyController.dispose();
    _degreeController.dispose();
    super.dispose();
  }
}

// ==================== LOCATION PICKER SCREEN ====================

class LocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _selectedAddress = 'Loading address...';
  bool _isLoadingLocation = false;
  bool _isLoadingAddress = false;
  
  // Permission dialog control
  bool _showPermissionDialog = true;
  String _selectedPermission = 'While using the app';
  String _selectedAccuracy = 'Precise';

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  Future<void> _checkAndRequestPermission() async {
    // Check if location permission is already granted
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.always || 
        permission == LocationPermission.whileInUse) {
      // Permission already granted, hide dialog and get location
      setState(() => _showPermissionDialog = false);
      _initializeLocation();
    } else {
      // Show permission dialog
      setState(() => _showPermissionDialog = true);
    }
  }

  Future<void> _initializeLocation() async {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _getAddressFromLatLng(_selectedLocation!);
    } else {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        setState(() => _isLoadingLocation = false);
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      _getAddressFromLatLng(_selectedLocation!);
      _moveCamera(_selectedLocation!);
    } catch (e) {
      print('❌ Error getting location: $e');
      setState(() => _isLoadingLocation = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isLoadingAddress = true);
    
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress = 
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      print('❌ Error getting address: $e');
      setState(() {
        _selectedAddress = 'Address not found';
        _isLoadingAddress = false;
      });
    }
  }

  void _moveCamera(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16),
      ),
    );
  }

  void _onMapTapped(LatLng position) {
    setState(() => _selectedLocation = position);
    _getAddressFromLatLng(position);
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, {
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'address': _selectedAddress,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          _selectedLocation == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation!,
                    zoom: 16,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  onTap: _onMapTapped,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue,
                      ),
                    ),
                  },
                ),

          // Permission Dialog Overlay (Only show when needed)
          if (_showPermissionDialog)
            Positioned(
              top: 60,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF1664CD),
                      size: 40,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Allow Maps to access this\ndevice\'s precise location?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2C49),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Accuracy Selection
                    Row(
                      children: [
                        Expanded(
                          child: _buildAccuracyOption('Precise', Icons.location_on),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: _buildAccuracyOption('Approximate', Icons.location_searching),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    // Permission Options
                    _buildPermissionButton('While using the app'),
                    const SizedBox(height: 10),
                    _buildPermissionButton('Only this time'),
                    const SizedBox(height: 10),
                    _buildPermissionButton('Don\'t allow'),
                  ],
                ),
              ),
            ),

          // Address Info Card (Only show when permission granted)
          if (!_showPermissionDialog)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF1664CD),
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selected Location',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLoadingAddress ? 'Loading...' : _selectedAddress,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1B2C49),
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // My Location Button (Only show when permission granted)
          if (!_showPermissionDialog)
            Positioned(
              bottom: 180,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                onPressed: _getCurrentLocation,
                child: _isLoadingLocation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.my_location,
                        color: Color(0xFF1664CD),
                      ),
              ),
            ),

          // Confirm Button (Only show when permission granted)
          if (!_showPermissionDialog)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _confirmLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1664CD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccuracyOption(String title, IconData icon) {
    final isSelected = _selectedAccuracy == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedAccuracy = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE9F0FF) : Colors.grey[100],
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? const Color(0xFF1664CD) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1664CD) : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF1664CD) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionButton(String title) {
    final isSelected = _selectedPermission == title;
    return GestureDetector(
      onTap: () async {
        setState(() => _selectedPermission = title);
        
        // Handle permission based on selection
        if (title == "Don't allow") {
          // User denied permission
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        } else {
          // Request permission and proceed
          LocationPermission permission = await Geolocator.requestPermission();
          
          if (permission == LocationPermission.denied || 
              permission == LocationPermission.deniedForever) {
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location permission denied')),
              );
            }
          } else {
            // Permission granted - hide dialog and get location
            setState(() => _showPermissionDialog = false);
            await _initializeLocation();
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE9F0FF) : const Color(0xFFF5F8FF),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFF1664CD) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF1664CD) : const Color(0xFF1B2C49),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}