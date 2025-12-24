import 'package:flutter/material.dart';


class DoctorMyScheduleScreen extends StatefulWidget {
  const DoctorMyScheduleScreen({super.key});

  @override
  State<DoctorMyScheduleScreen> createState() => _DoctorMyScheduleScreenState();
}

class _DoctorMyScheduleScreenState extends State<DoctorMyScheduleScreen> {
  bool onlineAppointment = true;
  final TextEditingController _feesController = TextEditingController();

  // ইউজার কোন টাইম স্লটটি সিলেক্ট করেছে তা ট্র্যাক করার জন্য (Day + Index)
  String selectedSlotKey = ""; 

  final List<Map<String, dynamic>> scheduleData = [
    {'day': 'Monday', 'enabled': true, 'slots': [{'start': '10:00 Am', 'end': '10:30 Am'}, {'start': '11:00 Am', 'end': '11:30 Am'}]},
    {'day': 'Tuesday', 'enabled': false, 'slots': [{'start': '09:00 Am', 'end': '09:30 Am'}]},
    {'day': 'Wednesday', 'enabled': false, 'slots': [{'start': '04:00 Pm', 'end': '04:30 Pm'}]},
    {'day': 'Thursday', 'enabled': false, 'slots': [{'start': '10:00 Am', 'end': '10:30 Am'}]},
    {'day': 'Friday', 'enabled': false, 'slots': [{'start': '10:00 Am', 'end': '10:30 Am'}]},
    {'day': 'Saturday', 'enabled': false, 'slots': [{'start': '10:00 Am', 'end': '10:30 Am'}]},
    {'day': 'Sunday', 'enabled': false, 'slots': [{'start': '10:00 Am', 'end': '10:30 Am'}]},
  ];

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
        title: const Text(
          'Appointment Setting',
          style: TextStyle(color: Color(0xFF1B2C49), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage your Video and physical\nConsultations',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Online Appointment Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F0FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.video_call_outlined, color: Color(0xFF1B2C49)),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      'Online Appointment',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1B2C49)),
                    ),
                  ),
                  Switch(
                    value: onlineAppointment,
                    activeColor: const Color(0xFF6C63FF),
                    onChanged: (val) => setState(() => onlineAppointment = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Fees Input
            const Text('Fees', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2C49))),
            const SizedBox(height: 10),
            TextField(
              controller: _feesController,
              decoration: InputDecoration(
                hintText: 'expl: 100 BDT',
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE9F0FF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 25),

            Row(
              children: const [
                Icon(Icons.access_time_filled, color: Color(0xFF3B71FE)),
                SizedBox(width: 10),
                Text('Weekly Schedule', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1B2C49))),
              ],
            ),
            const SizedBox(height: 15),

            // Schedule List
            ...scheduleData.asMap().entries.map((entry) => _buildDayItem(entry.value, entry.key)).toList(),

            const SizedBox(height: 20),

            // Save Changes Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Schedule Saved Successfully'), backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1664CD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayItem(Map<String, dynamic> data, int dayIndex) {
    bool isEnabled = data['enabled'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isEnabled ? const Color.fromARGB(255, 255, 255, 255) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isEnabled ? const Color(0xFF3B71FE) : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Day Selection Box (Clickable Area)
          InkWell(
            onTap: () {
              setState(() {
                scheduleData[dayIndex]['enabled'] = !scheduleData[dayIndex]['enabled'];
              });
            },
            borderRadius: BorderRadius.circular(15),
            child: ListTile(
              horizontalTitleGap: 0,
              leading: Checkbox(
                value: isEnabled,
                activeColor: const Color(0xFF1B2C49),
                onChanged: (val) {
                  setState(() {
                    scheduleData[dayIndex]['enabled'] = val;
                  });
                },
              ),
              title: Text(data['day'], style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1B2C49))),
            ),
          ),
          
          if (isEnabled) ...[
            const Divider(height: 1, color: Color(0xFFE9F0FF)),
            const SizedBox(height: 12),
            // টাইম স্লট ডিজাইন - পুরো রো সিলেক্ট হবে
            ...data['slots'].asMap().entries.map<Widget>((slotEntry) {
              int slotIndex = slotEntry.key;
              var slot = slotEntry.value;
              String slotKey = "${data['day']}_$slotIndex";
              bool isSelected = selectedSlotKey == slotKey;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 90, right: 90),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedSlotKey = slotKey; // ইউজার ক্লিক করলে সিলেক্ট হবে
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1664CD) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1664CD) : const Color(0xFFE9F0FF),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          slot['start'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF1B2C49),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            'To',
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          slot['end'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF1B2C49),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            
            TextButton.icon(
              onPressed: () {
                setState(() {
                  data['slots'].add({'start': '12:00 Pm', 'end': '12:30 Pm'});
                });
              },
              icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF3B71FE)),
              label: const Text('Add New Slot', style: TextStyle(color: Color(0xFF3B71FE), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}