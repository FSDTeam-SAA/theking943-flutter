import 'package:docmobi/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DoctorHelpSupportScreen extends StatelessWidget {
  const DoctorHelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B3267)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.helpSupport,
          style: const TextStyle(
            color: Color(0xFF0B3267),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(child: Text(l10n.helpSupportComingSoon)),
    );
  }
}
