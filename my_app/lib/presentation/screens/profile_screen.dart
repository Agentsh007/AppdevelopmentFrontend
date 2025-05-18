import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'package:my_app/presentation/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final token = authProvider.user!.token;
      final userId = authProvider.user!.id;
      try {
        final data = await ApiService.fetchProfile(token, userId);
        setState(() {
          profileData = data;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
          profileData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching profile: $e')));
      }
    } else {
      setState(() {
        isLoading = false;
        profileData = null;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          // Modern Sliver App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.teal.shade700, Colors.teal.shade400],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Profile Avatar
                    Positioned(
                      top: 80,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile picture tapped')),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.teal.shade600,
                              child: Text(
                                profileData != null
                                    ? profileData!['name'].toString().substring(0, 1).toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.teal.shade700,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                tooltip: 'Settings',
              ),
            ],
          ),
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : profileData == null
                      ? const Center(
                          child: Text(
                            "Failed to load profile or not logged in",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            // Profile Name and Email
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  profileData!['name'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profileData!['email'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Profile Details Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildDetailTile(
                                    icon: Icons.phone,
                                    label: 'Phone',
                                    value: profileData!['phone'] ?? 'N/A',
                                  ),
                                  const Divider(),
                                  _buildDetailTile(
                                    icon: Icons.medical_services,
                                    label: 'Blood Group',
                                    value: profileData!['blood_group'] ?? 'N/A',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Academic Information Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Academic Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildDetailTile(
                                    icon: Icons.school,
                                    label: 'University',
                                    value: profileData!['university']?['name'] ?? 'N/A',
                                  ),
                                  const Divider(),
                                  _buildDetailTile(
                                    icon: Icons.account_balance,
                                    label: 'Department',
                                    value: profileData!['academic_unit']?['name'] ?? 'N/A',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Edit Profile Button
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isEditing = !_isEditing;
                                  });
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   SnackBar(content: Text(_isEditing ? 'Editing enabled' : 'Editing disabled')),
                                  // );
                                  Navigator.pushNamed(context, '/edit-profile');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isEditing ? Colors.teal.shade600 : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isEditing ? Icons.check : Icons.edit,
                                        color: _isEditing ? Colors.white : Colors.black87,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isEditing ? 'Save Changes' : 'Edit Profile',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: _isEditing ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Logout/Login Button
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (authProvider.user != null) {
                                    authProvider.logout();
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pushNamed(context, '/login');
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 6,
                                  shadowColor: Colors.red.withOpacity(0.4),
                                ),
                                child: Text(
                                  authProvider.user != null ? 'Logout' : 'Login',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({required IconData icon, required String label, required String value}) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal, size: 28),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      ),
      onTap: _isEditing
          ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tapped on $label - Edit mode enabled')),
              );
            }
          : null,
    );
  }
}