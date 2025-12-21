import 'package:flutter/material.dart';

class DoctorMyScheduleScreen extends StatefulWidget {
  const DoctorMyScheduleScreen({super.key});

  @override
  State<DoctorMyScheduleScreen> createState() => _DoctorMyScheduleScreenState();
}

class _DoctorMyScheduleScreenState extends State<DoctorMyScheduleScreen> {
  bool onlineAppointment = true;
  final TextEditingController _feesController = TextEditingController(text: '500');
  
  final Map<String, Map<String, dynamic>> weekDays = {
    'Sunday': {'enabled': true, 'startTime': '09:00 am', 'endTime': '12:00 pm'},
    'Monday': {'enabled': false, 'startTime': '', 'endTime': ''},
    'Tuesday': {'enabled': true, 'startTime': '10:00 am', 'endTime': '12:00 pm'},
    'Wednesday': {'enabled': false, 'startTime': '', 'endTime': ''},
    'Thursday': {'enabled': true, 'startTime': '10:00 am', 'endTime': '12:00 pm'},
    'Friday': {'enabled': false, 'startTime': '', 'endTime': ''},
    'Saturday': {'enabled': true, 'startTime': '10:00 am', 'endTime': '12:00 pm'},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EEFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B3267)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Appointment Setting',
          style: TextStyle(
            color: Color(0xFF0B3267),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Online Appointment Toggle
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.videocam, color: Color(0xFF1664CD)),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      'Online Appointment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B3267),
                      ),
                    ),
                  ),
                  Switch(
                    value: onlineAppointment,
                    activeColor: const Color(0xFF1664CD),
                    onChanged: (value) {
                      setState(() {
                        onlineAppointment = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Fees Section
            const Text(
              'Fees',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3267),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _feesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter fees amount',
                  suffixText: 'BDT',
                  suffixStyle: TextStyle(
                    color: Color(0xFF1664CD),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Weekly Schedule Section
            const Text(
              'Weekly Schedule',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0B3267),
              ),
            ),
            const SizedBox(height: 10),
            
            ...weekDays.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildDaySchedule(
                  entry.key,
                  entry.value['enabled'],
                  entry.value['startTime'],
                  entry.value['endTime'],
                ),
              );
            }).toList(),
            
            const SizedBox(height: 30),
            
            // Save Changes Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B3267), Color(0xFF1664CD)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Schedule updated successfully'),
                        backgroundColor: Color(0xFF27AE60),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySchedule(String day, bool enabled, String startTime, String endTime) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? const Color(0xFF1664CD).withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: enabled,
                activeColor: const Color(0xFF1664CD),
                onChanged: (value) {
                  setState(() {
                    weekDays[day]!['enabled'] = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: enabled ? FontWeight.w600 : FontWeight.normal,
                    color: enabled ? const Color(0xFF0B3267) : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          weekDays[day]!['startTime'] = picked.format(context);
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EEFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            startTime.isEmpty ? 'Start Time' : startTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: startTime.isEmpty ? Colors.grey : const Color(0xFF0B3267),
                            ),
                          ),
                          const Icon(Icons.access_time, size: 18, color: Color(0xFF1664CD)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'To',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          weekDays[day]!['endTime'] = picked.format(context);
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EEFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            endTime.isEmpty ? 'End Time' : endTime,
                            style: TextStyle(
                              fontSize: 14,
                              color: endTime.isEmpty ? Colors.grey : const Color(0xFF0B3267),
                            ),
                          ),
                          const Icon(Icons.access_time, size: 18, color: Color(0xFF1664CD)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Add more time slots for $day')),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 18, color: const Color(0xFF1664CD)),
                  const SizedBox(width: 5),
                  Text(
                    'Add More',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF1664CD),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _feesController.dispose();
    super.dispose();
  }
}