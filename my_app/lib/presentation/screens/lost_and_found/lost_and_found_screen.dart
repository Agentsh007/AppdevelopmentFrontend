import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'package:my_app/presentation/services/api_service.dart';
import 'package:my_app/data/models/lost_and_found_item.dart';
import 'package:my_app/data/models/claim.dart';
import 'package:my_app/presentation/screens/lost_and_found/report_lost_found_screen.dart';
import 'package:my_app/presentation/screens/lost_and_found/item_detail_screen.dart';

class LostAndFoundHubScreen extends StatefulWidget {
  const LostAndFoundHubScreen({Key? key}) : super(key: key);

  @override
  _LostAndFoundHubScreenState createState() => _LostAndFoundHubScreenState();
}

class _LostAndFoundHubScreenState extends State<LostAndFoundHubScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  bool _isLoading = false;
  List<LostAndFoundItem> _items = [];
  List<Claim> _claims = [];
  List<LostAndFoundItem> _claimedItems = [];

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isLoggedIn) {
        Navigator.pushNamed(context, '/login');
        return;
      }

      final currentUserId = authProvider.user?.id;

      if (_selectedFilter == 'all') {
        final allItems = await ApiService.fetchLostAndFoundItems('all');
        _items = allItems.where((item) {
          if (item.user.id != currentUserId) {
            return item.approvalStatus == 'approved';
          }
          return true;
        }).toList();
      } else if (_selectedFilter == 'lost') {
        final lostItems = await ApiService.fetchLostAndFoundItems('lost');
        _items = lostItems.where((item) {
          if (item.user.id != currentUserId) {
            return item.approvalStatus == 'approved';
          }
          return true;
        }).toList();
      } else if (_selectedFilter == 'found') {
        final foundItems = await ApiService.fetchLostAndFoundItems('found');
        _items = foundItems.where((item) {
          if (item.user.id != currentUserId) {
            return item.approvalStatus == 'approved';
          }
          return true;
        }).toList();
      } else if (_selectedFilter == 'my-posts') {
        _items = await ApiService.fetchLostAndFoundItems('my-posts');
      } else if (_selectedFilter == 'my-claims') {
        // Fetch items the user has claimed
        final claimedItems = await ApiService.fetchLostAndFoundItems('my-claims');
        _claimedItems = claimedItems;
        List<Claim> allClaims = [];
        for (var item in claimedItems) {
          if (item.claimsUrl.isNotEmpty) {
            // Fetch all claims for the item, not just the user's claims
            final itemClaims = await ApiService.fetchClaims(
                item.postType == 'lost' ? 'lost' : 'found', item.id);
            allClaims.addAll(itemClaims);
          }
        }
        _claims = allClaims;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching items: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<LostAndFoundItem> _filteredItems() {
    if (_searchQuery.isEmpty) return _items;
    return _items.where((item) {
      return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost and Found Hub'),
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportLostFoundScreen()),
          ).then((_) => _fetchItems());
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                labelText: 'Search Items',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _selectedFilter,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: 'all', child: Text('All Items')),
                DropdownMenuItem(value: 'lost', child: Text('Lost Items')),
                DropdownMenuItem(value: 'found', child: Text('Found Items')),
                DropdownMenuItem(value: 'my-posts', child: Text('My Posts')),
                DropdownMenuItem(value: 'my-claims', child: Text('My Claims')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                  _items = [];
                  _claims = [];
                  _claimedItems = [];
                  _fetchItems();
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _selectedFilter == 'my-claims'
                    ? ListView.builder(
                        itemCount: _claims.length,
                        itemBuilder: (context, index) {
                          final claim = _claims[index];
                          final item = _claimedItems.firstWhere(
                            (item) => item.id == (claim.lostItemId ?? claim.foundItemId),
                            orElse: () => LostAndFoundItem(
                              id: -1,
                              user: User(id: -1, name: 'Unknown', detailUrl: ''),
                              title: 'Unknown Item',
                              description: 'Item not found',
                              approximateTime: 'N/A',
                              location: 'N/A',
                              status: 'N/A',
                              approvalStatus: 'N/A',
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                              media: [],
                              postType: 'N/A',
                              isAdmin: false,
                              detailUrl: '',
                              claimsUrl: '',
                            ),
                          );
                          return Card(
                            margin: EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text('Claim for: ${item.title}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Claim Description: ${claim.description}'),
                                  Text('Claimant: ${claim.claimant.name}'),
                                  Text('Item Description: ${item.description}'),
                                  Text('Claim Status: ${claim.status}'),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemDetailScreen(item: item),
                                  ),
                                ).then((_) => _fetchItems());
                              },
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: _filteredItems().length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems()[index];
                          return Card(
                            margin: EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: item.media.isNotEmpty
                                  ? Image.network(
                                      item.media.first.fileUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(Icons.image_not_supported),
                                    )
                                  : Icon(Icons.image_not_supported),
                              title: Text(item.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.description),
                                  if (_selectedFilter == 'my-posts')
                                    Text(
                                      'Approval Status: ${item.approvalStatus}',
                                      style: TextStyle(
                                        color: item.approvalStatus == 'approved'
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ItemDetailScreen(item: item),
                                  ),
                                ).then((_) => _fetchItems());
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}