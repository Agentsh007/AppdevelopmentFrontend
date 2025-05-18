import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_app/data/models/lost_and_found_item.dart';
import 'package:my_app/data/models/claim.dart';
import 'dart:developer' as developer;

class ApiService {
  static final String base = _getBaseUrl();
  static String _getBaseUrl() {
    if (Platform.isAndroid) {
      // Emulator
      return 'http://10.0.2.2:8000';
    } else {
      // iOS simulator or real device (both Android and iOS)
      return 'http://192.168.0.182:8000'; // Replace with your actual PC IP
    }
  }

  static final String baseUrl = '$base/api/lostandfound';
  static final String placesBaseUrl = '$base/api/places';

  static const FlutterSecureStorage storage = FlutterSecureStorage();

  // static Future<List<LostAndFoundItem>> fetchLostAndFoundItems(
  //   String endpoint,
  // ) async {
  //   final token = await storage.read(key: 'auth_token');
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/$endpoint'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       if (token != null) 'Authorization': 'Token $token',
  //     },
  //   );
  //   print(response.body);
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     final value =
  //         (data['results'] as List).map((json) {
  //           try {
  //             return LostAndFoundItem.fromJson(json as Map<String, dynamic>);
  //           } catch (e) {
  //             developer.log('Error parsing item: $json, Error: $e');
  //             return LostAndFoundItem(
  //               id: -1,
  //               user: User(id: -1, name: 'Unknown User', detailUrl: ''),
  //               title: 'Error',
  //               description: 'Failed to parse: $e',
  //               lostDate: null,
  //               foundDate: null,
  //               approximateTime: 'Unknown time',
  //               location: 'Unknown location',
  //               status: 'Unknown',
  //               approvalStatus: 'Pending',
  //               createdAt: DateTime.now(),
  //               updatedAt: DateTime.now(),
  //               media: [],
  //               postType: 'Unknown',
  //               isAdmin: false,
  //               detailUrl: '',
  //               claimsUrl: '',
  //               resolveUrl: null,
  //               approveUrl: null,
  //               university: null,
  //             );
  //           }
  //         }).toList();
  //     developer.log('Fetched items: $value');
  //     return value;
  //   } else {
  //     throw Exception('Failed to load items: ${response.statusCode}');
  //   }
  // }

  static Future<List<LostAndFoundItem>> fetchLostAndFoundItems(
    String endpoint,
  ) async {
    final token = await storage.read(key: 'auth_token');
    developer.log('Auth token: $token');

    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final url = '$baseUrl/$cleanEndpoint/';
    developer.log('Request URL: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Token $token',
        },
      );

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        developer.log('Parsed JSON: $data');

        List<dynamic> items;
        if (data is List) {
          items = data;
        } else if (data is Map<String, dynamic> && data.containsKey('results') && data['results'] is List) {
          items = data['results'];
        } else {
          throw Exception('Response does not contain a list of items or "results" key');
        }

        final value = items.map((json) {
          try {
            return LostAndFoundItem.fromJson(json as Map<String, dynamic>);
          } catch (e) {
            developer.log('Error parsing item: $json, Error: $e');
            return LostAndFoundItem(
              id: -1,
              user: User(id: -1, name: 'Unknown User', detailUrl: ''),
              title: 'Error',
              description: 'Failed to parse: $e',
              lostDate: null,
              foundDate: null,
              approximateTime: 'Unknown time',
              location: 'Unknown location',
              status: 'Unknown',
              approvalStatus: 'Pending',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              media: [],
              postType: 'Unknown',
              isAdmin: false,
              detailUrl: '',
              claimsUrl: '',
              resolveUrl: null,
              approveUrl: null,
              university: null,
            );
          }
        }).toList();
        developer.log('Fetched items: $value');
        return value;
      } else {
        throw Exception('Failed to load items: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      developer.log('Error in fetchLostAndFoundItems: $e');
      rethrow;
    }
  }
  static Future<LostAndFoundItem> fetchItemDetail(
    String endpoint,
    int id,
  ) async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint/$id/'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return LostAndFoundItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to load item: ${response.statusCode}, ${response.body}',
      );
    }
  }

  static Future<void> createLostItem(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('No authentication token found');

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/lost/'));
    request.headers['Authorization'] = 'Token $token';

    // Add text fields
    data.forEach((key, value) {
      if (value != null && key != 'media') {
        request.fields[key] = value.toString();
      }
    });

    // Add media file if present
    if (data['media'] != null) {
      File mediaFile = data['media'] as File;
      request.files.add(
        await http.MultipartFile.fromPath('media_files', mediaFile.path),
      );
    }

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to create lost item: ${response.statusCode}, ${responseBody.body}',
      );
    }
  }

  static Future<void> createFoundItem(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('No authentication token found');

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/found/'));
    request.headers['Authorization'] = 'Token $token';

    // Add text fields
    data.forEach((key, value) {
      if (value != null && key != 'media') {
        request.fields[key] = value.toString();
      }
    });

    // Add media file if present
    if (data['media'] != null) {
      File mediaFile = data['media'] as File;
      request.files.add(
        await http.MultipartFile.fromPath('media_files', mediaFile.path),
      );
    }

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to create found item: ${response.statusCode}, ${responseBody.body}',
      );
    }
  }

  static Future<List<Claim>> fetchClaims(String endpoint, int itemId) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint/$itemId/claims/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final value =
          (data['results'] as List)
              .map((json) => Claim.fromJson(json as Map<String, dynamic>))
              .toList();
      developer.log('Fetched claims: $value');
      return value;
    } else {
      throw Exception(
        'Failed to load claims: ${response.statusCode}, ${response.body}',
      );
    }
  }

  static Future<void> createClaim(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('No authentication token found');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/$endpoint/claim/'),
    );
    request.headers['Authorization'] = 'Token $token';

    // Add text fields
    data.forEach((key, value) {
      if (value != null && key != 'media') {
        request.fields[key] = value.toString();
      }
    });

    // Add media file if present
    if (data['media'] != null) {
      File mediaFile = data['media'] as File;
      request.files.add(
        await http.MultipartFile.fromPath('media_files', mediaFile.path),
      );
    }

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to create claim: ${response.statusCode}, ${responseBody.body}',
      );
    }
  }

  static Future<void> resolveItem(
    String endpoint,
    int itemId,
    Map<String, dynamic> data,
  ) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint/$itemId/resolve/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to resolve item: ${response.statusCode}, ${response.body}',
      );
    }
  }

  static Future<void> updateItem(
    String type,
    int itemId,
    Map<String, dynamic> data,
  ) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('No authentication token found');
    final url =
        type == 'lost'
            ? '$base/api/lostandfound/lost/$itemId/'
            : '$base/api/lostandfound/found/$itemId/';
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token', // Assuming token-based auth
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update item: ${response.statusCode}, ${response.body}',
      );
    }
  }

  static Future<Map<String, dynamic>?> fetchProfile(
    String token,
    int userId,
  ) async {
    final url = Uri.parse('$base/api/accounts/$userId/');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to load profile: ${response.statusCode}');
      return null;
    }
  }

  //for campus explore

  // New methods for Campus Explore

  static Future<List<Map<String, dynamic>>> fetchPlaces() async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('$placesBaseUrl/'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception('Failed to load places: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchUniversityPlaces() async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('$placesBaseUrl/universities/'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to load university places: ${response.statusCode}',
      );
    }
  }

  static Future<void> createPlace(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('No authentication token found');

    var request = http.MultipartRequest('POST', Uri.parse('$placesBaseUrl/'));
    request.headers['Authorization'] = 'Token $token';

    data.forEach((key, value) {
      if (value != null && key != 'media_files') {
        request.fields[key] = value.toString();
      }
    });

    if (data['media_files'] != null) {
      List<File> mediaFiles = data['media_files'] as List<File>;
      for (var mediaFile in mediaFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('media_files', mediaFile.path),
        );
      }
    }

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to create place: ${response.statusCode}, ${responseBody.body}',
      );
    }
  }

  static Future<void> updatePlace(
    int placeId,
    Map<String, dynamic> data,
  ) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('No authentication token found');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$placesBaseUrl/$placeId/update/'),
    );
    request.headers['Authorization'] = 'Token $token';

    data.forEach((key, value) {
      if (value != null && key != 'media_files') {
        request.fields[key] = value.toString();
      }
    });

    if (data['media_files'] != null) {
      List<File> mediaFiles = data['media_files'] as List<File>;
      for (var mediaFile in mediaFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('media_files', mediaFile.path),
        );
      }
    }

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode != 201) {
      throw Exception(
        'Failed to update place: ${response.statusCode}, ${responseBody.body}',
      );
    }
  }

  static Future<void> deletePlace(int placeId) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.delete(
      Uri.parse('$placesBaseUrl/$placeId/delete/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete place: ${response.statusCode}, ${response.body}',
      );
    }
  }

  static Future<void> recursiveDeletePlace(int placeId) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.delete(
      Uri.parse('$placesBaseUrl/$placeId/recursive-delete/'),
      headers: {'Authorization': 'Token $token'},
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to recursively delete place: ${response.statusCode}, ${response.body}',
      );
    }
  }

  static Future<List<Map<String, dynamic>>> searchPlaces(
    Map<String, dynamic> queryParams,
  ) async {
    final token = await storage.read(key: 'auth_token');
    final uri = Uri.parse(
      '$placesBaseUrl/search/',
    ).replace(queryParameters: queryParams);
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception(
        'Failed to search places: ${response.statusCode}, ${response.body}',
      );
    }
  }

  static Future<List<Map<String, dynamic>>> fetchPlaceTypes() async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('$placesBaseUrl/place-types/'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load place types: ${response.statusCode}');
    }
  }

  //for profile update
  static Future<void> updateProfile(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'auth_token');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.patch(
      Uri.parse('$base/api/accounts/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update profile: ${response.statusCode}, ${response.body}',
      );
    }
  }
}
