import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/catalog_product.dart';

class EvoqeApiException implements Exception {
  const EvoqeApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class EvoqeApi {
  static const int _vercelUploadLimitBytes = 4 * 1024 * 1024;

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
  static const String storeDomain = String.fromEnvironment(
    'SHOPIFY_STORE_DOMAIN',
    defaultValue: '',
  );

  static Future<void> verifyAuthenticatedSession() async {
    final response = await _get(Uri.parse('$baseUrl/api/v1/auth/me'));
    if (response.statusCode != HttpStatus.ok) {
      throw EvoqeApiException(_decodeError(response.body, response.statusCode));
    }
  }

  static Future<List<CatalogProduct>> fetchProducts() async {
    final products = <CatalogProduct>[];
    String? cursor;
    do {
      final query = <String, String>{'limit': '50'};
      if (storeDomain.isNotEmpty) query['store_domain'] = storeDomain;
      if (cursor != null) query['cursor'] = cursor;
      final uri = Uri.parse('$baseUrl/api/v1/products')
          .replace(queryParameters: query);
      final response = await _get(uri);
      if (response.statusCode != HttpStatus.ok) {
        throw EvoqeApiException(
          'Catalog request failed with HTTP ${response.statusCode}.',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['items'] is! List) {
        throw const EvoqeApiException(
          'The catalog API returned an invalid response.',
        );
      }
      for (final item in decoded['items'] as List<dynamic>) {
        if (item is Map<String, dynamic>) {
          products.add(CatalogProduct.fromJson(item));
        }
      }
      cursor = decoded['next_cursor'] as String?;
    } while (cursor != null);
    return products;
  }

  static Future<AssistantApiResult> sendAssistantMessage({
    required String message,
    required Map<String, String> preferences,
    String? storeDomain,
  }) async {
    final response = await _postJson(
      Uri.parse('$baseUrl/api/v1/assistant/chat'),
      {
        'message': message,
        'preferences': preferences,
        if ((storeDomain ?? EvoqeApi.storeDomain).isNotEmpty)
          'store_domain': storeDomain ?? EvoqeApi.storeDomain,
      },
    );
    if (response.statusCode != HttpStatus.ok) {
      throw EvoqeApiException(_decodeError(response.body, response.statusCode));
    }
    final decoded = _decodeObject(response.body, 'assistant');
    final reply = decoded['reply'];
    final rawProducts = decoded['products'];
    if (reply is! String || rawProducts is! List) {
      throw const EvoqeApiException(
        'The assistant API returned an invalid response.',
      );
    }
    return AssistantApiResult(
      reply: reply,
      products: rawProducts
          .whereType<Map<String, dynamic>>()
          .map(CatalogProduct.fromJson)
          .toList(),
    );
  }

  static Future<LookbookApiResult> analyzeLookbook({
    required String description,
    File? image,
    String? storeDomain,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    final boundary = 'evoqe-${DateTime.now().microsecondsSinceEpoch}';
    try {
      final request = await client.postUrl(
        Uri.parse('$baseUrl/api/v1/lookbooks/analyze'),
      );
      _addAuthHeader(request.headers);
      request.headers.contentType = ContentType(
        'multipart',
        'form-data',
        parameters: {'boundary': boundary},
      );

      final body = BytesBuilder();
      void addField(String name, String value) {
        body.add(
          utf8.encode(
            '--$boundary\r\n'
            'Content-Disposition: form-data; name="$name"\r\n\r\n'
            '$value\r\n',
          ),
        );
      }

      addField('description', description);
      final effectiveStoreDomain = storeDomain ?? EvoqeApi.storeDomain;
      if (effectiveStoreDomain.isNotEmpty) {
        addField('store_domain', effectiveStoreDomain);
      }
      if (image != null) {
        final imageBytes = await image.readAsBytes();
        _ensureVercelUploadSize([imageBytes]);
        final extension = image.path.toLowerCase().split('.').last;
        final mimeType = switch (extension) {
          'png' => 'image/png',
          'webp' => 'image/webp',
          _ => 'image/jpeg',
        };
        final fileName = image.uri.pathSegments.isEmpty
            ? 'lookbook-image'
            : image.uri.pathSegments.last;
        body.add(
          utf8.encode(
            '--$boundary\r\n'
            'Content-Disposition: form-data; name="image"; '
            'filename="$fileName"\r\n'
            'Content-Type: $mimeType\r\n\r\n',
          ),
        );
        body.add(imageBytes);
        body.add(utf8.encode('\r\n'));
      }
      body.add(utf8.encode('--$boundary--\r\n'));
      final payload = body.takeBytes();
      request.contentLength = payload.length;
      request.add(payload);
      final response = await request.close();
      final responseBody = await utf8.decoder.bind(response).join();
      if (response.statusCode != HttpStatus.ok) {
        throw EvoqeApiException(
          _decodeError(responseBody, response.statusCode),
        );
      }
      final decoded = _decodeObject(responseBody, 'lookbook');
      final analysis = decoded['analysis'];
      final rawProducts = decoded['products'];
      if (analysis is! Map<String, dynamic> || rawProducts is! List) {
        throw const EvoqeApiException(
          'The lookbook API returned an invalid response.',
        );
      }
      return LookbookApiResult(
        summary: analysis['summary'] as String? ?? '',
        aesthetics: _stringList(analysis['aesthetics']),
        colors: _stringList(analysis['colors']),
        categories: _stringList(analysis['categories']),
        occasions: _stringList(analysis['occasions']),
        products: rawProducts
            .whereType<Map<String, dynamic>>()
            .map(CatalogProduct.fromJson)
            .toList(),
      );
    } on SocketException catch (error) {
      throw EvoqeApiException('Could not connect to EVOQE backend: $error');
    } on HttpException catch (error) {
      throw EvoqeApiException('Could not analyze lookbook: $error');
    } finally {
      client.close(force: true);
    }
  }

  static Future<String> createCheckout({
    required String storeDomain,
    required List<Map<String, Object>> lines,
  }) async {
    final response = await _postJson(Uri.parse('$baseUrl/api/v1/checkout'), {
      'store_domain': storeDomain,
      'lines': lines,
    });
    if (response.statusCode != HttpStatus.ok) {
      throw EvoqeApiException(_decodeError(response.body, response.statusCode));
    }
    final decoded = _decodeObject(response.body, 'checkout');
    final checkoutUrl = decoded['checkout_url'];
    if (checkoutUrl is! String ||
        Uri.tryParse(checkoutUrl)?.scheme != 'https') {
      throw const EvoqeApiException(
        'The checkout API returned an invalid checkout URL.',
      );
    }
    return checkoutUrl;
  }

  static Future<String> startMakeupTryOn({
    required int productId,
    required String variantId,
    required String storeDomain,
    required Uint8List selfieBytes,
  }) async {
    _ensureVercelUploadSize([selfieBytes]);
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    final boundary = 'evoqe-${DateTime.now().microsecondsSinceEpoch}';
    try {
      final request = await client.postUrl(
        Uri.parse('$baseUrl/api/v1/try-on/makeup'),
      );
      _addAuthHeader(request.headers);
      request.headers.contentType = ContentType(
        'multipart',
        'form-data',
        parameters: {'boundary': boundary},
      );
      void addField(String name, String value) {
        request.add(
          utf8.encode(
            '--$boundary\r\n'
            'Content-Disposition: form-data; name="$name"\r\n\r\n'
            '$value\r\n',
          ),
        );
      }

      addField('store_domain', storeDomain);
      addField('product_id', productId.toString());
      addField('variant_id', variantId);
      final isPng =
          selfieBytes.length >= 8 &&
          selfieBytes[0] == 0x89 &&
          selfieBytes[1] == 0x50 &&
          selfieBytes[2] == 0x4e &&
          selfieBytes[3] == 0x47;
      request.add(
        utf8.encode(
          '--$boundary\r\n'
          'Content-Disposition: form-data; name="user_image"; '
          'filename="selfie.${isPng ? 'png' : 'jpg'}"\r\n'
          'Content-Type: ${isPng ? 'image/png' : 'image/jpeg'}\r\n\r\n',
        ),
      );
      request.add(selfieBytes);
      request.add(utf8.encode('\r\n--$boundary--\r\n'));
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode != HttpStatus.accepted) {
        throw EvoqeApiException(_decodeError(body, response.statusCode));
      }
      dynamic decoded;
      try {
        decoded = jsonDecode(body);
      } on FormatException {
        throw const EvoqeApiException(
          'The makeup try-on API returned invalid JSON.',
        );
      }
      if (decoded is! Map<String, dynamic> || decoded['task_id'] is! String) {
        throw const EvoqeApiException(
          'The makeup try-on API returned an invalid task response.',
        );
      }
      return decoded['task_id'] as String;
    } on SocketException catch (error) {
      throw EvoqeApiException('Could not connect to EVOQE backend: $error');
    } on HttpException catch (error) {
      throw EvoqeApiException('Could not start makeup try-on: $error');
    } finally {
      client.close(force: true);
    }
  }

  static Future<MakeupTryOnResult> getMakeupTryOnStatus(String taskId) async {
    final response = await _get(
      Uri.parse('$baseUrl/api/v1/try-on/makeup/$taskId'),
    );
    if (response.statusCode != HttpStatus.ok) {
      throw EvoqeApiException(_decodeError(response.body, response.statusCode));
    }
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const EvoqeApiException(
        'The makeup try-on API returned invalid JSON.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const EvoqeApiException(
        'The makeup try-on API returned an invalid status response.',
      );
    }
    final status = decoded['status'];
    final resultUrl = decoded['result_url'];
    final error = decoded['error'];
    if (status is! String ||
        (resultUrl != null && resultUrl is! String) ||
        (error != null && error is! String)) {
      throw const EvoqeApiException(
        'The makeup try-on API returned an invalid status response.',
      );
    }
    return MakeupTryOnResult(
      status: status,
      resultUrl: resultUrl as String?,
      error: error as String?,
    );
  }

  static Future<ProductTryOnTask> startProductTryOn({
    required int productId,
    required String storeDomain,
    required Uint8List userImage,
    required String? gender,
  }) async {
    _ensureVercelUploadSize([userImage]);
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    final boundary = 'evoqe-${DateTime.now().microsecondsSinceEpoch}';
    final isPng =
        userImage.length >= 8 &&
        userImage[0] == 0x89 &&
        userImage[1] == 0x50 &&
        userImage[2] == 0x4e &&
        userImage[3] == 0x47;
    try {
      final request = await client.postUrl(
        Uri.parse('$baseUrl/api/v1/try-on/fashion'),
      );
      _addAuthHeader(request.headers);
      request.headers.contentType = ContentType(
        'multipart',
        'form-data',
        parameters: {'boundary': boundary},
      );
      void addField(String name, String value) {
        request.add(
          utf8.encode(
            '--$boundary\r\n'
            'Content-Disposition: form-data; name="$name"\r\n\r\n'
            '$value\r\n',
          ),
        );
      }

      addField('store_domain', storeDomain);
      addField('product_id', productId.toString());
      if (gender != null) addField('gender', gender.toLowerCase());
      request.add(
        utf8.encode(
          '--$boundary\r\n'
          'Content-Disposition: form-data; name="user_image"; '
          'filename="profile.${isPng ? 'png' : 'jpg'}"\r\n'
          'Content-Type: ${isPng ? 'image/png' : 'image/jpeg'}\r\n\r\n',
        ),
      );
      request.add(userImage);
      request.add(utf8.encode('\r\n--$boundary--\r\n'));
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      if (response.statusCode != HttpStatus.accepted) {
        throw EvoqeApiException(_decodeError(body, response.statusCode));
      }
      dynamic decoded;
      try {
        decoded = jsonDecode(body);
      } on FormatException {
        throw const EvoqeApiException(
          'The fashion try-on API returned invalid JSON.',
        );
      }
      if (decoded is! Map<String, dynamic> ||
          decoded['task_id'] is! String ||
          decoded['task_type'] is! String) {
        throw const EvoqeApiException(
          'The fashion try-on API returned an invalid task response.',
        );
      }
      return ProductTryOnTask(
        taskId: decoded['task_id'] as String,
        taskType: decoded['task_type'] as String,
      );
    } on SocketException catch (error) {
      throw EvoqeApiException('Could not connect to EVOQE backend: $error');
    } on HttpException catch (error) {
      throw EvoqeApiException('Could not start fashion try-on: $error');
    } finally {
      client.close(force: true);
    }
  }

  static Future<ProductTryOnTask> startCustomFashionTryOn({
    required String storeDomain,
    required Uint8List userImage,
    required Uint8List referenceImage,
    required String? gender,
  }) async {
    _ensureVercelUploadSize([userImage, referenceImage]);
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    final boundary = 'evoqe-${DateTime.now().microsecondsSinceEpoch}';
    try {
      final request = await client.postUrl(
        Uri.parse('$baseUrl/api/v1/try-on/fashion'),
      );
      _addAuthHeader(request.headers);
      request.headers.contentType = ContentType(
        'multipart',
        'form-data',
        parameters: {'boundary': boundary},
      );
      final body = BytesBuilder();
      void addField(String name, String value) {
        body.add(
          utf8.encode(
            '--$boundary\r\n'
            'Content-Disposition: form-data; name="$name"\r\n\r\n'
            '$value\r\n',
          ),
        );
      }

      void addImage(String name, String fileName, Uint8List image) {
        final isPng = _isPng(image);
        body.add(
          utf8.encode(
            '--$boundary\r\n'
            'Content-Disposition: form-data; name="$name"; '
            'filename="$fileName.${isPng ? 'png' : 'jpg'}"\r\n'
            'Content-Type: ${isPng ? 'image/png' : 'image/jpeg'}\r\n\r\n',
          ),
        );
        body.add(image);
        body.add(utf8.encode('\r\n'));
      }

      addField('store_domain', storeDomain);
      if (gender != null) addField('gender', gender.toLowerCase());
      addImage('user_image', 'profile', userImage);
      addImage('reference_image', 'garment', referenceImage);
      body.add(utf8.encode('--$boundary--\r\n'));
      final payload = body.takeBytes();
      request.contentLength = payload.length;
      request.add(payload);
      final response = await request.close();
      final responseBody = await utf8.decoder.bind(response).join();
      if (response.statusCode != HttpStatus.accepted) {
        throw EvoqeApiException(
          _decodeError(responseBody, response.statusCode),
        );
      }
      final decoded = _decodeObject(responseBody, 'fashion try-on');
      final taskId = decoded['task_id'];
      final taskType = decoded['task_type'];
      if (taskId is! String || taskType is! String) {
        throw const EvoqeApiException(
          'The fashion try-on API returned an invalid task response.',
        );
      }
      return ProductTryOnTask(taskId: taskId, taskType: taskType);
    } on SocketException catch (error) {
      throw EvoqeApiException('Could not connect to EVOQE backend: $error');
    } on HttpException catch (error) {
      throw EvoqeApiException('Could not start fashion try-on: $error');
    } finally {
      client.close(force: true);
    }
  }

  static Future<ProductTryOnStatus> getProductTryOnStatus({
    required String taskId,
    required String taskType,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/try-on/fashion/$taskId')
        .replace(queryParameters: {'task_type': taskType});
    final response = await _get(uri);
    if (response.statusCode != HttpStatus.ok) {
      throw EvoqeApiException(_decodeError(response.body, response.statusCode));
    }
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const EvoqeApiException(
        'The fashion try-on API returned invalid JSON.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const EvoqeApiException(
        'The fashion try-on API returned an invalid status response.',
      );
    }
    final status = decoded['status'];
    final resultUrl = decoded['result_url'];
    final error = decoded['error'];
    if (status is! String ||
        (resultUrl != null && resultUrl is! String) ||
        (error != null && error is! String)) {
      throw const EvoqeApiException(
        'The fashion try-on API returned an invalid status response.',
      );
    }
    return ProductTryOnStatus(
      status: status,
      resultUrl: resultUrl as String?,
      error: error as String?,
    );
  }

  static Future<_ApiResponse> _get(Uri uri) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.getUrl(uri);
      _addAuthHeader(request.headers);
      final response = await request.close();
      final body = await utf8.decoder.bind(response).join();
      return _ApiResponse(response.statusCode, body);
    } on SocketException catch (error) {
      throw EvoqeApiException('Could not connect to EVOQE backend: $error');
    } on HttpException catch (error) {
      throw EvoqeApiException('Could not load catalog: $error');
    } finally {
      client.close(force: true);
    }
  }

  static Future<_ApiResponse> _postJson(
    Uri uri,
    Map<String, Object?> payload,
  ) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 20);
    try {
      final request = await client.postUrl(uri);
      _addAuthHeader(request.headers);
      request.headers.contentType = ContentType.json;
      final body = utf8.encode(jsonEncode(payload));
      request.contentLength = body.length;
      request.add(body);
      final response = await request.close();
      final responseBody = await utf8.decoder.bind(response).join();
      return _ApiResponse(response.statusCode, responseBody);
    } on SocketException catch (error) {
      throw EvoqeApiException('Could not connect to EVOQE backend: $error');
    } on HttpException catch (error) {
      throw EvoqeApiException(
        'Could not send request to EVOQE backend: $error',
      );
    } finally {
      client.close(force: true);
    }
  }

  static void _addAuthHeader(HttpHeaders headers) {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token != null) {
      headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
  }

  static String _decodeError(String body, int statusCode) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['detail'] is String) {
        return decoded['detail'] as String;
      }
    } on FormatException {
      return 'Request failed with HTTP $statusCode.';
    }
    return 'Request failed with HTTP $statusCode.';
  }

  static Map<String, dynamic> _decodeObject(String body, String feature) {
    dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw EvoqeApiException('The $feature API returned invalid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw EvoqeApiException('The $feature API returned an invalid response.');
    }
    return decoded;
  }

  static List<String> _stringList(Object? value) =>
      value is List ? value.whereType<String>().toList() : const [];

  static bool _isPng(Uint8List bytes) =>
      bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47;

  static void _ensureVercelUploadSize(List<Uint8List> images) {
    final host = Uri.tryParse(baseUrl)?.host ?? '';
    if (!host.endsWith('.vercel.app')) return;
    final totalBytes = images.fold<int>(
      0,
      (total, image) => total + image.length,
    );
    if (totalBytes > _vercelUploadLimitBytes) {
      throw const EvoqeApiException(
        'Vercel accepts try-on and lookbook uploads up to 4 MB total. Choose smaller photos and try again.',
      );
    }
  }
}

class AssistantApiResult {
  const AssistantApiResult({required this.reply, required this.products});

  final String reply;
  final List<CatalogProduct> products;
}

class LookbookApiResult {
  const LookbookApiResult({
    required this.summary,
    required this.aesthetics,
    required this.colors,
    required this.categories,
    required this.occasions,
    required this.products,
  });

  final String summary;
  final List<String> aesthetics;
  final List<String> colors;
  final List<String> categories;
  final List<String> occasions;
  final List<CatalogProduct> products;
}

class MakeupTryOnResult {
  const MakeupTryOnResult({
    required this.status,
    required this.resultUrl,
    required this.error,
  });

  final String status;
  final String? resultUrl;
  final String? error;
}

class ProductTryOnTask {
  const ProductTryOnTask({required this.taskId, required this.taskType});

  final String taskId;
  final String taskType;
}

class ProductTryOnStatus {
  const ProductTryOnStatus({
    required this.status,
    required this.resultUrl,
    required this.error,
  });

  final String status;
  final String? resultUrl;
  final String? error;
}

class _ApiResponse {
  const _ApiResponse(this.statusCode, this.body);

  final int statusCode;
  final String body;
}
