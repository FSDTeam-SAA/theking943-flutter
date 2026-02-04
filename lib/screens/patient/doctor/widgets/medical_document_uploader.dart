import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:docmobi/l10n/app_localizations.dart';

class MedicalDocumentUploader extends StatelessWidget {
  final List<XFile> documents;
  final VoidCallback onPickDocuments;
  final XFile? paymentScreenshot;
  final VoidCallback onPickPayment;
  final bool showPaymentUpload;

  const MedicalDocumentUploader({
    super.key,
    required this.documents,
    required this.onPickDocuments,
    required this.paymentScreenshot,
    required this.onPickPayment,
    required this.showPaymentUpload,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildWhiteCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.uploadMedicalDocs,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onPickDocuments,
                child: _buildUploadBox(
                  context,
                  Icons.cloud_upload_outlined,
                  l10n.tapToUpload,
                ),
              ),
              if (documents.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: documents
                        .map(
                          (f) => Chip(
                            label: Text(
                              f.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),

        if (showPaymentUpload) ...[
          const SizedBox(height: 16),
          _buildWhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.uploadPaymentScreenshot,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onPickPayment,
                  child: _buildUploadBox(
                    context,
                    Icons.cloud_upload_outlined,
                    l10n.tapToUploadPayment,
                  ),
                ),
                if (paymentScreenshot != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Chip(
                      label: Text(
                        paymentScreenshot!.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
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

  Widget _buildUploadBox(BuildContext context, IconData icon, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D53C1).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0D53C1).withOpacity(0.3),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF0D53C1)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0D53C1),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
