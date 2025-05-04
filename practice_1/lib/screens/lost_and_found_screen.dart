import 'dart:io';
import 'package:flutter/material.dart';
import 'package:practice_1/colors/colors.dart';
import 'package:practice_1/models/lost_item.dart';
import 'package:practice_1/models/notification.dart';
import 'package:practice_1/screens/notification_screen.dart';
import 'package:practice_1/screens/report_lost_item_screen.dart';
import 'package:practice_1/services/api_service.dart';
import 'package:practice_1/services/notification_service.dart';
import 'package:practice_1/services/session_service.dart';
import 'package:google_fonts/google_fonts.dart';

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  String? _currentUserEmail;
  final SessionService _sessionService = SessionService();
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  List<LostItem> _lostItems = [];
  bool _isLoading = false;
  Map<String, bool> _markingAsFound = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _fetchLostItems();
  }

  Future<void> _loadCurrentUser() async {
    final email = await _sessionService.getSessionEmail();
    setState(() {
      _currentUserEmail = email;
    });
    if (_currentUserEmail == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _fetchLostItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final token = await _sessionService.getSessionToken();
      if (token != null) {
        final items = await _apiService.getLostItems(token);
        setState(() {
          _lostItems = items;
          _markingAsFound = {for (var item in items) item.id: false};
        });
      }
    } catch (e) {
      _showSnackBar('Error fetching lost items: $e', Colors.redAccent);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsFound(String itemId, String ownerEmail, int itemIndex) async {
    setState(() {
      _markingAsFound[itemId] = true;
    });
    try {
      final token = await _sessionService.getSessionToken();
      final currentUserEmail = await _sessionService.getSessionEmail();
      if (token != null && currentUserEmail != null) {
        await _apiService.markItemAsFound(itemId, token);
        setState(() {
          _lostItems[itemIndex] = _lostItems[itemIndex].copyWith(found: true);
          _markingAsFound[itemId] = false;
        });
        final notification = AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userEmail: ownerEmail,
          message: 'Your lost item "${_lostItems[itemIndex].name}" has been found!',
          timestamp: DateTime.now(),
          finderEmail: currentUserEmail,
        );
        await _notificationService.sendNotification(notification);
        _showSnackBar('Item marked as found!', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Error marking item as found: $e', Colors.redAccent);
    } finally {
      setState(() {
        _markingAsFound[itemId] = false;
      });
    }
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      final token = await _sessionService.getSessionToken();
      if (token != null) {
        await _apiService.deleteLostItem(itemId, token);
        setState(() {
          _lostItems.removeWhere((item) => item.id == itemId);
        });
        _showSnackBar('Item deleted successfully', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Error deleting item: $e', Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showItemDetails(LostItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryText(context).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lost Item Details',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText(context),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(item.found),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.found ? Colors.green.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.found ? 'Found' : 'Lost',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: item.found ? Colors.green : Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Hero(
                  tag: 'item-image-${item.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.imagePath.isNotEmpty
                        ? Image.network(
                            '${ApiService.baseUrl}${item.imagePath}',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                width: double.infinity,
                                color: AppColors.secondaryText(context).withOpacity(0.1),
                                child: const Center(child: CircularProgressIndicator()),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 200,
                              width: double.infinity,
                              color: AppColors.secondaryText(context).withOpacity(0.1),
                              child: Icon(
                                Icons.image_not_supported,
                                color: AppColors.secondaryText(context),
                              ),
                            ),
                          )
                        : Container(
                            height: 200,
                            width: double.infinity,
                            color: AppColors.secondaryText(context).withOpacity(0.1),
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.secondaryText(context),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.label, 'Item Name', item.name.isNotEmpty ? item.name : 'Not specified'),
                _buildDetailRow(Icons.description, 'Description', item.description),
                _buildDetailRow(Icons.location_on, 'Location', item.location.isNotEmpty ? item.location : 'Not specified'),
                _buildDetailRow(Icons.person, 'Reported by', item.userEmail),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_currentUserEmail != item.userEmail && !item.found)
                      ElevatedButton.icon(
                        onPressed: () {
                          final index = _lostItems.indexWhere((element) => element.id == item.id);
                          _markAsFound(item.id, item.userEmail, index);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check, size: 20),
                        label: Text(
                          'Mark as Found',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          elevation: 2,
                        ),
                      ),
                    if (_currentUserEmail == item.userEmail)
                      ElevatedButton.icon(
                        onPressed: () {
                          _deleteItem(item.id);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete, size: 20),
                        label: Text(
                          'Delete',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          elevation: 2,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.buttonAccent(context), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.secondaryText(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.primaryText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lost & Found',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryText(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLostItems,
        color: AppColors.buttonAccent(context),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.buttonAccent(context)))
            : _lostItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.secondaryText(context).withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No lost items found',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.secondaryText(context),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _lostItems.length,
                    itemBuilder: (context, index) {
                      final item = _lostItems[index];
                      final isOwner = _currentUserEmail == item.userEmail;
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: InkWell(
                          onTap: () => _showItemDetails(item),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.background(context).withOpacity(0.9),
                                  AppColors.background(context),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Hero(
                                    tag: 'item-image-${item.id}',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: item.imagePath.isNotEmpty
                                          ? Image.network(
                                              '${ApiService.baseUrl}${item.imagePath}',
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: AppColors.secondaryText(context).withOpacity(0.1),
                                                  child: const Center(child: CircularProgressIndicator()),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                width: 80,
                                                height: 80,
                                                color: AppColors.secondaryText(context).withOpacity(0.1),
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: AppColors.secondaryText(context),
                                                ),
                                              ),
                                            )
                                          : Container(
                                              width: 80,
                                              height: 80,
                                              color: AppColors.secondaryText(context).withOpacity(0.1),
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: AppColors.secondaryText(context),
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name.isNotEmpty ? item.name : 'Unnamed Item',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryText(context),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.description,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: AppColors.secondaryText(context),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 300),
                                          transitionBuilder: (child, animation) => ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          ),
                                          child: Container(
                                            key: ValueKey(item.found),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: item.found ? Colors.green.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              item.found ? 'Found' : 'Lost',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: item.found ? Colors.green : Colors.redAccent,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isOwner)
                                        IconButton(
                                          onPressed: () => _deleteItem(item.id),
                                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                                          tooltip: 'Delete',
                                        ),
                                      if (!isOwner && !item.found)
                                        AnimatedSwitcher(
                                          duration: const Duration(milliseconds: 300),
                                          child: _markingAsFound[item.id] == true
                                              ? const SizedBox(
                                                  key: ValueKey('loading'),
                                                  width: 24,
                                                  height: 24,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                                  ),
                                                )
                                              : ElevatedButton(
                                                  key: ValueKey('found-button-${item.id}'),
                                                  onPressed: () {
                                                    _markAsFound(item.id, item.userEmail, index);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green,
                                                    foregroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                    elevation: 2,
                                                  ),
                                                  child: Text(
                                                    'Found',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportLostItemScreen(onSubmit: _fetchLostItems),
            ),
          );
        },
        backgroundColor: AppColors.buttonAccent(context),
        child: const Icon(Icons.add, color: Colors.white),
        elevation: 4,
      ),
    );
  }
}

extension LostItemExtension on LostItem {
  LostItem copyWith({
    String? id,
    String? userEmail,
    String? name,
    String? description,
    String? location,
    String? imagePath,
    bool? found,
  }) {
    return LostItem(
      id: id ?? this.id,
      userEmail: userEmail ?? this.userEmail,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
      found: found ?? this.found,
    );
  }
}