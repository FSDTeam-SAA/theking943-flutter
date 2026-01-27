import 'package:docmobi/l10n/app_localizations.dart';
import 'package:docmobi/screens/patient/appointments/patient_appointments_screen.dart';
import 'package:docmobi/screens/patient/profile/dependents_list_screen.dart';
import 'package:docmobi/screens/patient/profile/help_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:docmobi/screens/patient/profile/personal_info_screen.dart';
import 'package:docmobi/screens/patient/profile/change_password_screen.dart';
import 'package:docmobi/screens/patient/navigation/patient_main_navigation.dart';

import 'package:provider/provider.dart' as legacy_provider;
import '../../../providers/user_provider.dart';
import '../../../services/auth_service.dart';
import '../../../screens/auth/sign_in_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:docmobi/providers/locale_provider.dart';

class PatientProfileScreen extends ConsumerStatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  ConsumerState<PatientProfileScreen> createState() =>
      _PatientProfileScreenState();
}

class _PatientProfileScreenState extends ConsumerState<PatientProfileScreen> {
  String selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      legacy_provider.Provider.of<UserProvider>(
        context,
        listen: false,
      ).fetchUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0B3267)),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const PatientMainNavigation(),
                ),
                (route) => false,
              );
            }
          },
        ),
        title: Text(
          l10n.appTitle,
          style: const TextStyle(
            color: Color(0xFF0B3267),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: legacy_provider.Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Get user data
          final user = userProvider.user;
          final userName = user?.fullName ?? 'The king';
          // final userLocation = 'Keim - Germany'; // Static for now
          final userLocation = user?.address ?? 'Location not set';

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// Profile Picture Section
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user?.profileImage != null
                          ? NetworkImage(user!.profileImage!)
                          : const AssetImage('assets/images/doctor1.png')
                                as ImageProvider,
                    ),
                    // Loading indicator overlay
                    if (userProvider.isLoading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),

                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B3267),
                  ),
                ),
                const SizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      userLocation,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// Menu Items
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Personal Info',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PersonalInfoScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'My Appointment',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientAppointmentsScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.group_add_outlined,
                  title: 'My Dependents',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DependentsListScreen(),
                      ),
                    );
                  },
                ),

                _buildMenuItem(
                  icon: Icons.lock_outline,
                  title: l10n.changePassword,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),

                // Language Selector
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.language, color: Color(0xFF1664CD)),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            'Language',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF0B3267),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        DropdownButton<String>(
                          value: currentLocale.languageCode == 'en'
                              ? 'English'
                              : 'Arabic',
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: [
                            DropdownMenuItem(
                              value: 'English',
                              child: Text(l10n.english),
                            ),
                            DropdownMenuItem(
                              value: 'Arabic',
                              child: Text(l10n.arabic),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == 'English') {
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(const Locale('en'));
                            } else {
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(const Locale('ar'));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                /// Logout Button with API Integration
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () => _showLogoutConfirmationDialog(context),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // Logout Dialog with API Integration
  void _showLogoutConfirmationDialog(BuildContext context) {
    // নতুন নাম
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );

              await AuthService().logout();
              legacy_provider.Provider.of<UserProvider>(
                context,
                listen: false,
              ).clearUser();

              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) =>
                        const SignInScreen(userType: 'patient'),
                  ),
                  (route) => false,
                );
              }
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF1664CD)),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0B3267),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
