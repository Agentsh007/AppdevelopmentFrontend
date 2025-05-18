import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/domain/providers/auth_provider.dart';
import 'package:my_app/presentation/services/api_service.dart';
import 'package:my_app/data/models/lost_and_found_item.dart';
import 'package:my_app/data/models/claim.dart';
import 'package:my_app/presentation/widgets/custom_text_field.dart';

class ItemDetailScreen extends StatefulWidget {
  final LostAndFoundItem item;

  const ItemDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _isLoading = false;
  final _claimDescriptionController = TextEditingController();
  bool _isResolved = false;
  bool _hasClaimed = false;
  String _currentStatus = ''; // Track the current status locally

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.item.status; // Initialize with the item's status
    _checkIfClaimed();
  }

  Future<void> _checkIfClaimed() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUserId = authProvider.user?.id;
      if (currentUserId != null && widget.item.claimsUrl.isNotEmpty) {
        final claims = await ApiService.fetchClaims(
            widget.item.postType == 'lost' ? 'lost' : 'found', widget.item.id);
        setState(() {
          _hasClaimed = claims.any((claim) => claim.claimant.id == currentUserId);
        });
      }
    } catch (e) {
      print('Error checking claims: $e');
    }
  }

  Future<void> _createClaim() async {
    if (_claimDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Claim description is required')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = {
        widget.item.postType == 'lost' ? 'lost_item' : 'found_item': widget.item.id,
        'description': _claimDescriptionController.text,
      };
      await ApiService.createClaim(
          widget.item.postType == 'lost' ? 'lost' : 'found', data);

      // Update the item's status to 'claimed'
      final updateData = {
        'status': 'claimed',
      };
      await ApiService.updateItem(
          widget.item.postType == 'lost' ? 'lost' : 'found', widget.item.id, updateData);

      setState(() {
        _hasClaimed = true; // Prevent further claims
        _currentStatus = 'claimed'; // Update local status
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Claim submitted successfully')),
      );
      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting claim: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resolveItem() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final data = {
        'status': widget.item.postType == 'lost' ? 'found' : 'returned',
        'resolved_by': authProvider.user?.id,
      };
      await ApiService.resolveItem(
          widget.item.postType == 'lost' ? 'lost' : 'found', widget.item.id, data);
      setState(() {
        _isResolved = true;
        _currentStatus = widget.item.postType == 'lost' ? 'found' : 'returned';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item resolved successfully')),
      );
      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resolving item: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _claimDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isOwner = authProvider.user?.id == widget.item.user.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (widget.item.media.isNotEmpty)
              Image.network(
                widget.item.media.first.fileUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported),
              ),
            const SizedBox(height: 16),
            Text(
              widget.item.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.description,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${widget.item.location}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              widget.item.postType == 'lost'
                  ? 'Lost Date: ${widget.item.lostDate ?? "N/A"}'
                  : 'Found Date: ${widget.item.foundDate ?? "N/A"}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Approximate Time: ${widget.item.approximateTime}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${_isResolved ? (widget.item.postType == "lost" ? "Found" : "Returned") : _currentStatus}',
              style: TextStyle(fontSize: 16, color: _isResolved ? Colors.green : (_currentStatus == 'claimed' ? Colors.orange : null)),
            ),
            const SizedBox(height: 8),
            Text(
              'Approval Status: ${widget.item.approvalStatus}',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (isOwner && _currentStatus == 'open' && !_isResolved && widget.item.approvalStatus == 'approved')
              ElevatedButton(
                onPressed: _isLoading ? null : _resolveItem,
                child: Text('Resolve Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            if (!isOwner && _currentStatus == 'open' && widget.item.approvalStatus == 'approved' && !_hasClaimed) ...[
              CustomTextField(
                controller: _claimDescriptionController,
                labelText: 'Claim Description',
                obscureText: false,
                validator: (value) =>
                    value!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _createClaim,
                child: Text('Submit Claim'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}