import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../core/constants/api_constants.dart';
import 'token_service.dart';

// ─── ServiceResult: wrapper trả về từ mọi method của ApiService ──────────────

class ServiceResult<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  const ServiceResult({
    required this.success,
    required this.message,
    required this.statusCode,
    this.data,
  });

  factory ServiceResult.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ServiceResult(
      success:    json['success'] as bool? ?? false,
      message:    json['message'] as String? ?? '',
      statusCode: json['statusCode'] as int? ?? 0,
      data:       json['data'] != null && fromData != null
                    ? fromData(json['data'])
                    : null,
    );
  }
}

// ─── Auth Interceptor ─────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  final TokenService _tokenService;
  final Dio _dio;
  final Logger _log = Logger();

  _AuthInterceptor(this._tokenService, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Chỉ xử lý 401 — token hết hạn
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    _log.w('Access token expired — attempting refresh...');

    final refreshToken = await _tokenService.getRefreshToken();

    // Không có refresh token → đăng xuất
    if (refreshToken == null) {
      _log.e('No refresh token found — logging out');
      await _tokenService.clearAllTokens();
      return handler.reject(err);
    }

    try {
      // Gọi endpoint refresh (dùng Dio mới để tránh loop interceptor)
      final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final refreshRes = await refreshDio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      final newAccess  = refreshRes.data['data']['accessToken']  as String;
      final newRefresh = refreshRes.data['data']['refreshToken'] as String;

      await _tokenService.saveTokens(
        accessToken:  newAccess,
        refreshToken: newRefresh,
      );

      _log.i('Token refreshed — retrying original request');

      // Retry request gốc với token mới
      final retryOpts = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newAccess';

      final retryRes = await _dio.fetch<dynamic>(retryOpts);
      return handler.resolve(retryRes);
    } on DioException catch (e) {
      // Refresh cũng 401 → clear hết, để app navigate về Login
      _log.e('Refresh failed (${e.response?.statusCode}) — clearing tokens');
      await _tokenService.clearAllTokens();
      return handler.reject(err);
    }
  }
}

// ─── ApiService (Dio wrapper) ─────────────────────────────────────────────────

class ApiService {
  late final Dio _dio;
  final TokenService _tokenService;
  final Logger _log = Logger();

  ApiService({TokenService? tokenService})
      : _tokenService = tokenService ?? TokenService() {
    _dio = Dio(
      BaseOptions(
        baseUrl:        ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout:    const Duration(seconds: 30),
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.json.value,
          HttpHeaders.acceptHeader:      ContentType.json.value,
        },
      ),
    );

    // Auth interceptor (token attach + 401 retry)
    _dio.interceptors.add(_AuthInterceptor(_tokenService, _dio));

    // Log interceptor — chỉ bật ở debug
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request:        true,
          requestBody:    true,
          responseBody:   true,
          responseHeader: false,
          error:          true,
          logPrint: (obj) => _log.d(obj),
        ),
      );
    }
  }

  // ─── Helper methods ─────────────────────────────────────────────────────────

  Future<ServiceResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromData,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParams,
    );
    return ServiceResult.fromJson(res.data!, fromData);
  }

  Future<ServiceResult<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromData,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(path, data: data);
    return ServiceResult.fromJson(res.data!, fromData);
  }

  Future<ServiceResult<T>> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromData,
  }) async {
    final res = await _dio.put<Map<String, dynamic>>(path, data: data);
    return ServiceResult.fromJson(res.data!, fromData);
  }

  Future<ServiceResult<T>> delete<T>(
    String path, {
    T Function(dynamic)? fromData,
  }) async {
    final res = await _dio.delete<Map<String, dynamic>>(path);
    return ServiceResult.fromJson(res.data!, fromData);
  }

  Future<ServiceResult<T>> postMultipart<T>(
    String path, {
    required FormData formData,
    T Function(dynamic)? fromData,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return ServiceResult.fromJson(res.data!, fromData);
  }
}
