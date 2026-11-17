import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:kelontongku/core/constants/api_constants.dart';
import 'package:kelontongku/features/stok/models/product_model.dart';

class ProductService {
  static const Duration _timeout = Duration(seconds: 10);

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.readBarang))
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Gagal memuat data barang (HTTP ${response.statusCode})',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw Exception('Respon server tidak sesuai (harus berupa JSON Array)');
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    } on TimeoutException {
      throw Exception(
        'Koneksi timeout. Pastikan server API aktif dan dapat diakses.',
      );
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke server (${ApiConstants.baseUrl}). Periksa jaringan Anda.',
      );
    } on FormatException {
      throw Exception('Respon server bukan JSON yang valid.');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> createProduct(ProductModel product) async {
    return _postForm(
      url: ApiConstants.createBarang,
      body: product.toFormMap(),
      defaultError: 'Gagal menambahkan barang',
    );
  }

  Future<String> updateProduct(ProductModel product) async {
    final body = product.toFormMap()..['id'] = product.id.toString();
    return _postForm(
      url: ApiConstants.updateBarang,
      body: body,
      defaultError: 'Gagal memperbarui barang',
    );
  }

  Future<String> deleteProduct(int id) async {
    return _postForm(
      url: ApiConstants.deleteBarang,
      body: {'id': id.toString()},
      defaultError: 'Gagal menghapus barang',
    );
  }

  Future<String> _postForm({
    required String url,
    required Map<String, String> body,
    required String defaultError,
  }) async {
    try {
      final response = await http
          .post(Uri.parse(url), body: body)
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('$defaultError (HTTP ${response.statusCode})');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final success = decoded['success'] == true;
        final message = decoded['message']?.toString() ?? '';
        if (!success) {
          throw Exception(message.isNotEmpty ? message : defaultError);
        }
        return message.isNotEmpty ? message : 'Berhasil';
      }

      throw Exception('Format respon server tidak valid.');
    } on TimeoutException {
      throw Exception(
        'Koneksi timeout. Pastikan server API aktif dan dapat diakses.',
      );
    } on SocketException {
      throw Exception(
        'Tidak dapat terhubung ke server (${ApiConstants.baseUrl}). Periksa jaringan Anda.',
      );
    } on FormatException {
      throw Exception('Respon server bukan JSON yang valid.');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
