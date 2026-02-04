import 'package:flutter/material.dart';
import 'package:docmobi/l10n/app_localizations.dart';

class AppointmentTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeSelected;
  final String title;

  const AppointmentTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _buildWhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildTypeOption(
                'assets/icons/physical_visit.png',
                "Physical Visit",
                l10n.physicalVisit,
                l10n.payAtClinic,
              ),
              const SizedBox(width: 15),
              _buildTypeOption(
                'assets/icons/video_call.png',
                "Video Call",
                l10n.videoCall,
                l10n.onlinePayment,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );

  Widget _buildTypeOption(
    String image,
    String typeKey,
    String displayTitle,
    String displaySubtitle,
  ) {
    bool isSelected = selectedType == typeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTypeSelected(typeKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0D53C1)
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Image.asset(
                image,
                color: isSelected ? const Color(0xFF0D53C1) : Colors.black54,
                width: 30,
                height: 30,
              ),
              const SizedBox(height: 5),
              Text(
                displayTitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF0D53C1) : Colors.black87,
                ),
              ),
              Text(
                displaySubtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
