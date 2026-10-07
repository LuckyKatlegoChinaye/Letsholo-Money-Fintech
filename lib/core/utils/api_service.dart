import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiException implements Exception {

  ApiException({
    required this.message,
    this.statusCode,
    this.code,
  });
  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {

  ApiService({required Dio dio}) : _dio = dio;
  final Dio _dio;
  final Logger _logger = Logger();

  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      _logger.d('GET $endpoint');
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      _logger.e('DioException: $e');
      throw _handleError(e);
    } catch (e) {
      _logger.e('Unexpected error: $e');
      rethrow;
    }
  }

  Future<T> post<T>(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.d('POST $endpoint with data: $data');
      final response = await _dio.post(endpoint, data: data);
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      _logger.e('DioException: $e');
      throw _handleError(e);
    } catch (e) {
      _logger.e('Unexpected error: $e');
      rethrow;
    }
  }

  Future<T> put<T>(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.d('PUT $endpoint with data: $data');
      final response = await _dio.put(endpoint, data: data);
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      _logger.e('DioException: $e');
      throw _handleError(e);
    } catch (e) {
      _logger.e('Unexpected error: $e');
      rethrow;
    }
  }

  Future<T> patch<T>(
    String endpoint, {
    required Map<String, dynamic> data,
  }) async {
    try {
      _logger.d('PATCH $endpoint with data: $data');
      final response = await _dio.patch(endpoint, data: data);
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      _logger.e('DioException: $e');
      throw _handleError(e);
    } catch (e) {
      _logger.e('Unexpected error: $e');
      rethrow;
    }
  }

  Future<T> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      _logger.d('DELETE $endpoint');
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      _logger.e('DioException: $e');
      throw _handleError(e);
    } catch (e) {
      _logger.e('Unexpected error: $e');
      rethrow;
    }
  }

  T _handleResponse<T>(Response response) {
    _logger.d('Response status: ${response.statusCode}');
    _logger.d('Response data: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      if (data is Map && data['success'] == true) {
        return data['data'] ?? data as T;
      }
      return data as T;
    } else {
      throw ApiException(
        message: response.data?['message'] ?? 'Unknown error occurred',
        statusCode: response.statusCode,
      );
    }
  }

  ApiException _handleError(DioException error) {
    String message = 'Unknown error occurred';
    final int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout';
        break;
      case DioExceptionType.badResponse:
        message = error.response?.data?['message'] ?? 'Bad response';
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'Network error';
        break;
      case DioExceptionType.badCertificate:
        message = 'Bad certificate';
        break;
      case DioExceptionType.unknown:
        message = 'Unknown error';
        break;
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      code: error.response?.data?['code'],
    );
  }
}
