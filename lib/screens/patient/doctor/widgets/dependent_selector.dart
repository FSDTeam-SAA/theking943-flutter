import 'package:flutter/material.dart';
import 'package:docmobi/l10n/app_localizations.dart';
import 'package:docmobi/models/dependent_model.dart';

class DependentSelector extends StatelessWidget {
  final DependentModel? selectedDependent;
  final List<DependentModel> dependents;
  final ValueChanged<DependentModel?> onDependentSelected;
  final VoidCallback onAddNewDependent;
  final String title;

  const DependentSelector({
    super.key,
    required this.selectedDependent,
    required this.dependents,
    required this.onDependentSelected,
    required this.onAddNewDependent,
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
          const SizedBox(height: 12),

          _buildSelectForOption(
            icon: Icons.person,
            label: l10n.myself,
            isSelected: selectedDependent == null,
            onTap: () => onDependentSelected(null),
          ),

          if (dependents.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.orSelectDependent,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ...dependents.map(
              (dep) => _buildSelectForOption(
                icon: dep.gender?.toLowerCase() == 'male'
                    ? Icons.boy
                    : Icons.girl,
                label: dep.displayName,
                subtitle: dep.age,
                isSelected: selectedDependent?.id == dep.id,
                onTap: () => onDependentSelected(dep),
              ),
            ),
          ],

          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onAddNewDependent,
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF0D53C1),
            ),
            label: Text(
              l10n.addNewDependent,
              style: const TextStyle(
                color: Color(0xFF0D53C1),
                fontWeight: FontWeight.bold,
              ),
            ),
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
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );

  Widget _buildSelectForOption({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D53C1).withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D53C1) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0D53C1) : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF0D53C1)),
          ],
        ),
      ),
    );
  }
}
