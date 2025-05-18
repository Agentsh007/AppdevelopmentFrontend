import 'package:my_app/data/models/user_model.dart';

class Media {
  final String id;
  final String fileUrl;

  Media({required this.id, required this.fileUrl});

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
    );
  }
}

class LostAndFoundItem {
  final int id;
  final User user;
  final String title;
  final String description;
  final String? lostDate;
  final String? foundDate;
  final String approximateTime;
  final String location;
  final String status;
  final String approvalStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Media> media;
  final String postType;
  final bool isAdmin;
  final String detailUrl;
  final String claimsUrl;
  final String? resolveUrl;
  final String? approveUrl;
  final int? university;

  LostAndFoundItem({
    required this.id,
    required this.user,
    required this.title,
    required this.description,
    this.lostDate,
    this.foundDate,
    required this.approximateTime,
    required this.location,
    required this.status,
    required this.approvalStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.media,
    required this.postType,
    required this.isAdmin,
    required this.detailUrl,
    required this.claimsUrl,
    this.resolveUrl,
    this.approveUrl,
    this.university,
  });

  factory LostAndFoundItem.fromJson(Map<String, dynamic> json) {
    print('Parsing JSON: $json'); // Log the JSON for debugging
    return LostAndFoundItem(
      id: json['id'] as int? ?? -1,
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {'id': -1, 'name': 'Unknown User', 'detail_url': ''}),
      title: json['title'] as String? ?? 'No title',
      description: json['description'] as String? ?? 'No description',
      lostDate: json['lost_date'] as String?,
      foundDate: json['found_date'] as String?,
      approximateTime: json['approximate_time'] as String? ?? 'Unknown time',
      location: json['location'] as String? ?? 'Unknown location',
      status: json['status'] as String? ?? 'Unknown',
      approvalStatus: json['approval_status'] as String? ?? 'Pending',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
      media: (json['media'] as List<dynamic>? ?? []).map((mediaJson) => Media.fromJson(mediaJson as Map<String, dynamic>)).toList(),
      postType: json['post_type'] as String? ?? 'Unknown',
      isAdmin: json['is_admin'] as bool? ?? false,
      detailUrl: json['detail_url'] as String? ?? '',
      claimsUrl: json['claims_url'] as String? ?? '',
      resolveUrl: json['resolve_url'] as String?,
      approveUrl: json['approve_url'] as String?,
      university: json['university'] as int?,
    );
  }
}

class User {
  final int id;
  final String name;
  final String detailUrl;

  User({required this.id, required this.name, required this.detailUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? -1,
      name: json['name'] as String? ?? 'Unknown User',
      detailUrl: json['detail_url'] as String? ?? '',
    );
  }
}