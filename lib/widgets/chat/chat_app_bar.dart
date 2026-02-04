import 'package:flutter/material.dart';
import 'package:docmobi/widgets/custom_image.dart';
import 'package:docmobi/services/agora_chat_service.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userName;
  final String? userAvatar;
  final String placeholderAsset;
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback onCancelSelection;
  final VoidCallback onDeleteSelected;
  final VoidCallback onBack;
  final List<Widget>? actions;

  const ChatAppBar({
    super.key,
    this.userName,
    this.userAvatar,
    this.placeholderAsset = 'assets/images/doctor1.png',
    required this.isSelectionMode,
    required this.selectedCount,
    required this.onCancelSelection,
    required this.onDeleteSelected,
    required this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFF),
      elevation: 0,
      leading: isSelectionMode
          ? IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: onCancelSelection,
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
              onPressed: onBack,
            ),
      title: isSelectionMode
          ? Text(
              '$selectedCount selected',
              style: const TextStyle(color: Colors.black, fontSize: 18),
            )
          : Row(
              children: [
                Stack(
                  children: [
                    ClipOval(
                      child: CustomImage(
                        imageUrl: userAvatar,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholderAsset: placeholderAsset,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName ?? 'User',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      FutureBuilder<bool>(
                        future: AgoraChatService.instance.checkConnection(),
                        builder: (context, snapshot) {
                          final isLive = snapshot.data ?? false;
                          return Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: isLive ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isLive ? 'Online' : 'Offline',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isLive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
      actions: isSelectionMode
          ? [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDeleteSelected,
              ),
              const SizedBox(width: 10),
            ]
          : actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
