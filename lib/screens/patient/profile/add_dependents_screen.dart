import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Add intl to pubspec.yaml for date formatting

class AddDependentScreen extends ConsumerStatefulWidget {
  const AddDependentScreen({super.key});

  @override
  ConsumerState<AddDependentScreen> createState() => _AddDependentScreenState();
}

class _AddDependentScreenState extends ConsumerState<AddDependentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _medicalNotesController = TextEditingController();
  
  // State Variables
  DateTime? _selectedDate;
  String? _selectedRelationship;
  String _selectedGender = 'Male';

  final List<String> _relationships = [
    'Child',
    'Spouse',
    'Father',
    'Mother',
    'Brother',
    'Sister',
    'Grandparent',
    'Other'
  ];

  // Theme Colors
  final Color _cardBackgroundColor = const Color.fromRGBO(229, 238, 255, 1);
  final Gradient _primaryButtonGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0B3267), Color(0xFF1664CD)], // Your Blue Theme
    stops: [0.3016, 1.0],
  );
  
  // Custom Red Gradient for "Cancel" or "Delete" actions
  final Gradient _dangerButtonGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF512F), Color(0xFFDD2476)], // Modern vibrant red gradient
  );

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _medicalNotesController.dispose();
    super.dispose();
  }

  // Date Picker Helper
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF0B3267), // Calendar header color
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Dependent",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFormCard(),
              const SizedBox(height: 30),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        // Optional: Add subtle shadow if you want depth
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Basic Information"),
          const SizedBox(height: 15),
          
          // Relationship Dropdown
          _buildDropdownField(),
          const SizedBox(height: 15),

          // Name Field
          _buildTextField(
            controller: _nameController,
            label: "Full Name",
            icon: Icons.person_outline,
            validator: (v) => v!.isEmpty ? "Name is required" : null,
          ),
          const SizedBox(height: 15),

          // Date of Birth
          _buildDatePickerField(),
          const SizedBox(height: 20),

          _buildSectionTitle("Gender"),
          const SizedBox(height: 10),
          _buildGenderSelector(),
          const SizedBox(height: 20),

          _buildSectionTitle("Contact Details"),
          const SizedBox(height: 15),
          
          // Parent Contact (Read Only / Info)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.grey),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Parent/Guardian Contact (Primary)",
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                      const Text(
                        "The king - Note: Your user info will be used.",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Dependent Contact (Optional)
          _buildTextField(
            controller: _contactController,
            label: "Dependent's Contact (if applicable)",
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          
          const SizedBox(height: 20),
          _buildSectionTitle("Additional Information"),
          const SizedBox(height: 15),
          
          // Medical Notes
          _buildTextField(
            controller: _medicalNotesController,
            label: "Medical Notes / Allergies (Optional)",
            maxLines: 3,
            icon: null, // No icon for big text area
          ),
        ],
      ),
    );
  }

  // --- Widget Helpers ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0B3267),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF0B3267), size: 20) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0B3267)),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRelationship,
          hint: Text(
            "Relationship (e.g. Child, Spouse)",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0B3267)),
          items: _relationships.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedRelationship = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: Color(0xFF0B3267), size: 20),
            const SizedBox(width: 12),
            Text(
              _selectedDate == null
                  ? "Date of Birth"
                  : DateFormat('dd MMM, yyyy').format(_selectedDate!),
              style: TextStyle(
                color: _selectedDate == null ? Colors.grey.shade400 : Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: ['Male', 'Female', 'Other'].map((gender) {
        final isSelected = _selectedGender == gender;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedGender = gender),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0B3267) : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                gender,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF0B3267) : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save Button (Blue Gradient)
        Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            gradient: _primaryButtonGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1664CD).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // TODO: Add Logic to Save Dependent via Riverpod
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Processing Data...")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text(
              "Save Dependent",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        
        const SizedBox(height: 15),

        // Cancel Button (Red Gradient)
        Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
            gradient: _dangerButtonGradient,
            borderRadius: BorderRadius.circular(30),
             boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF512F).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}