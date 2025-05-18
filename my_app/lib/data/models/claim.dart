import 'package:my_app/data/models/lost_and_found_item.dart'; 

class Claim {
  final int id;
  final User claimant;
  final String description;
  final String status;
  final int? lostItemId;
  final int? foundItemId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Claim({
    required this.id,
    required this.claimant,
    required this.description,
    required this.status,
    this.lostItemId,
    this.foundItemId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Claim.fromJson(Map<String, dynamic> json) {
    return Claim(
      id: json['id'] as int? ?? -1,
      claimant: User.fromJson(json['claimant'] as Map<String, dynamic>? ?? {'id': -1, 'name': 'Unknown', 'detail_url': ''}),
      description: json['description'] as String? ?? 'No description',
      status: json['status'] as String? ?? 'pending',
      lostItemId: json['lost_item'] as int?,
      foundItemId: json['found_item'] as int?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
    );
  }
}