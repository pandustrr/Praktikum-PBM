import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/produk_model.dart';
import '../utils/constants.dart';

class ApiService {
  final _storage = const FlutterSecureStorage();
  final String _baseUrl = AppConstants.baseUrl;

  Future<Map<String, String>> _getHeaders({bool withToken = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (withToken) {
      String? token = await _storage.read(key: 'token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> login(String nim, String password) async {
    final url = Uri.https(_baseUrl, '/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(withToken: false),
        body: jsonEncode({
          'username': nim,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        String token = data['data']['token'];
        await _storage.write(key: 'token', value: token);
        return {'success': true, 'message': 'Login Berhasil'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login Gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan: $e'};
    }
  }

  Future<List<ProdukModel>> fetchProducts() async {
    final url = Uri.https(_baseUrl, '/api/products');
    try {
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body)['data'];
        
        List list;
        if (responseData is List) {
          list = responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          // Jika data dibungkus lagi (biasanya untuk paginasi)
          list = responseData['data'];
        } else {
          list = [];
        }
        
        return list.map((json) => ProdukModel.dariJson(json)).toList();
      } else {
        throw Exception('Gagal load produk');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> saveDraft(ProdukModel product) async {
    final url = Uri.https(_baseUrl, '/api/products');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(product.keJson()),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  Future<bool> submitFinal(ProdukModel product) async {
    final url = Uri.https(_baseUrl, '/api/products/submit');
    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(product.keJson()),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    final url = Uri.https(_baseUrl, '/api/products/$id');
    try {
      final response = await http.delete(url, headers: await _getHeaders());
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }
}
