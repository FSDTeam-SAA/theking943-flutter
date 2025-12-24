import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EarningOverviewScreen(),
    ));

class EarningOverviewScreen extends StatefulWidget {
  const EarningOverviewScreen({super.key});

  @override
  State<EarningOverviewScreen> createState() => _EarningOverviewScreenState();
}

class _EarningOverviewScreenState extends State<EarningOverviewScreen> {
  // বর্তমান সিলেক্টেড পিরিয়ড
  String selectedPeriod = 'Weekly';

  // ডামি ডাটা (ট্যাব চেঞ্জ হলে এগুলো আপডেট হবে)
  Map<String, dynamic> displayData = {
    'total': '\$4,500',
    'physical': '\$4,500',
    'video': '\$2,500',
    'chart': [120, 200, 150, 80, 70, 110, 130]
  };

  // ট্যাব পরিবর্তন করার ফাংশন
  void _updateData(String period) {
    setState(() {
      selectedPeriod = period;
      if (period == 'Daily') {
        displayData = {
          'total': '\$850',
          'physical': '\$500',
          'video': '\$350',
          'chart': [40, 90, 60, 120, 150, 80, 100]
        };
      } else if (period == 'Weekly') {
        displayData = {
          'total': '\$4,500',
          'physical': '\$4,500',
          'video': '\$2,500',
          'chart': [120, 200, 150, 80, 70, 110, 130]
        };
      } else {
        displayData = {
          'total': '\$18,200',
          'physical': '\$12,000',
          'video': '\$6,200',
          'chart': [100, 140, 180, 200, 160, 130, 190]
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar( 
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () {
      Navigator.pop(context); // এটি অ্যাপের আগের পেজে ফিরিয়ে নিয়ে যাবে
    },
  ),
        title: const Text(
          'Earning Overview',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track your income across all appointment types.',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 15),
            ),
            const SizedBox(height: 25),

            // --- Toggle Buttons with Bottom Border ---
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildToggleButton('Daily'),
                  _buildToggleButton('Weekly'),
                  _buildToggleButton('Monthly'),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // --- Total Earning Card ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300, width: 1),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF2D5AF0),
                    child: Icon(Icons.attach_money, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Earning', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(displayData['total'], 
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('↑ 8.2% More than last $selectedPeriod', 
                        style: TextStyle(color: Colors.green.shade600, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // --- Small Cards ---
            Row(
              children: [
                Expanded(child: _buildSmallCard('Physical Appointment', displayData['physical'], '↑ 8.2%', true)),
                const SizedBox(width: 15),
                Expanded(child: _buildSmallCard('Video Appointment', displayData['video'], '↓ 4.2%', false)),
              ],
            ),
            const SizedBox(height: 25),

            // --- Bar Chart Container ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: CustomBarChart(chartData: displayData['chart']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label) {
    bool isSelected = selectedPeriod == label;
    return GestureDetector(
      onTap: () => _updateData(label),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D5AF0) : const Color(0xFFF1F4FF),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallCard(String title, String amount, String percent, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFF1F4FF),
                child: Icon(Icons.person, size: 16, color: Color(0xFF2D5AF0)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 12),
          Text(amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('$percent ${isPositive ? 'More' : 'Less'}',
              style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontSize: 10)),
        ],
      ),
    );
  }
}

class CustomBarChart extends StatelessWidget {
  final List<int> chartData;
  const CustomBarChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Tue', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(chartData.length, (index) {
            return Column(
              children: [
                Text('${chartData[index]}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 12,
                  height: chartData[index].toDouble() * 0.7,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C77F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
                Text(days[index], style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            );
          }),
        ),
      ],
    );
  }
}