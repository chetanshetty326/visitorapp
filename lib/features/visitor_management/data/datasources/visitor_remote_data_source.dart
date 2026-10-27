import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/visitor_model.dart';

abstract class VisitorRemoteDataSource {
  Future<List<VisitorModel>> getVisitors();
  Future<VisitorModel> getVisitorById(String id);
  Future<VisitorModel> registerVisitor(VisitorModel visitor);
  Future<VisitorModel> updateVisitor(VisitorModel visitor);
  Future<void> deleteVisitor(String id);
  Future<VisitorModel> updateVisitorStatus({
    required String id,
    required String status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
  });
}

class VisitorRemoteDataSourceImpl implements VisitorRemoteDataSource {
  final Dio dio;
  final SharedPreferences? sharedPreferences;

  static const String _cachedVisitorsKey = 'CACHED_VISITORS_LIST';

  // In-memory fallback cache to ensure the app never crashes when offline
  static final List<VisitorModel> _fallbackStorage = [];

  VisitorRemoteDataSourceImpl({
    required this.dio,
    this.sharedPreferences,
  }) {
    _loadFromCache();
  }

  void _loadFromCache() {
    if (_fallbackStorage.isEmpty && sharedPreferences != null) {
      final jsonStr = sharedPreferences!.getString(_cachedVisitorsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        try {
          final decoded = jsonDecode(jsonStr) as List;
          _fallbackStorage.addAll(
            decoded.map((e) => VisitorModel.fromJson(e as Map<String, dynamic>)),
          );
        } catch (_) {}
      }
    }
  }

  Future<void> _saveToCache(List<VisitorModel> list) async {
    if (sharedPreferences != null) {
      try {
        final jsonList = list.map((v) => v.toJson()).toList();
        await sharedPreferences!.setString(_cachedVisitorsKey, jsonEncode(jsonList));
      } catch (_) {}
    }
  }

  String get _endpointUrl => '${ApiConstants.baseUrl}${ApiConstants.visitorsEndpoint}';

  @override
  Future<List<VisitorModel>> getVisitors() async {
    try {
      final response = await dio.get(_endpointUrl);
      if (response.statusCode == 200 && response.data is List) {
        final list = (response.data as List)
            .map((e) => VisitorModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Update fallback & disk cache
        _fallbackStorage.clear();
        _fallbackStorage.addAll(list);
        await _saveToCache(_fallbackStorage);

        return list;
      }
      throw ServerException(message: 'Invalid response format from server');
    } on DioException catch (e) {
      _loadFromCache();
      if (_fallbackStorage.isNotEmpty) {
        return List<VisitorModel>.from(_fallbackStorage);
      }
      throw _handleDioError(e);
    }
  }

  @override
  Future<VisitorModel> getVisitorById(String id) async {
    try {
      final response = await dio.get('$_endpointUrl/$id');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return VisitorModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw NotFoundException('Visitor with ID $id not found');
      }
    } on DioException catch (e) {
      // Check fallback storage
      final index = _fallbackStorage.indexWhere((v) => v.id == id);
      if (index != -1) {
        return _fallbackStorage[index];
      }
      throw _handleDioError(e);
    }
  }

  @override
  Future<VisitorModel> registerVisitor(VisitorModel visitor) async {
    try {
      // Server-generated ID from MockAPI
      final response = await dio.post(
        _endpointUrl,
        data: visitor.toJson(includeId: false),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final created = VisitorModel.fromJson(response.data as Map<String, dynamic>);
        _fallbackStorage.insert(0, created);
        await _saveToCache(_fallbackStorage);
        return created;
      }
      throw ServerException(message: 'Failed to create visitor on server');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<VisitorModel> updateVisitor(VisitorModel visitor) async {
    try {
      final response = await dio.put(
        '$_endpointUrl/${visitor.id}',
        data: visitor.toJson(),
      );
      if (response.statusCode == 200) {
        final updated = VisitorModel.fromJson(response.data as Map<String, dynamic>);
        final idx = _fallbackStorage.indexWhere((v) => v.id == visitor.id);
        if (idx != -1) _fallbackStorage[idx] = updated;
        await _saveToCache(_fallbackStorage);
        return updated;
      }
      throw ServerException(message: 'Failed to update visitor on server');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteVisitor(String id) async {
    try {
      final response = await dio.delete('$_endpointUrl/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        _fallbackStorage.removeWhere((v) => v.id == id);
        await _saveToCache(_fallbackStorage);
        return;
      }
      throw ServerException(message: 'Failed to delete visitor from server');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<VisitorModel> updateVisitorStatus({
    required String id,
    required String status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
  }) async {
    final updateData = <String, dynamic>{'status': status};
    if (checkInTime != null) {
      updateData['check_in_time'] = checkInTime.toIso8601String();
    }
    if (checkOutTime != null) {
      updateData['check_out_time'] = checkOutTime.toIso8601String();
    }

    try {
      // Use PUT or PATCH supported by MockAPI
      Response response;
      try {
        response = await dio.put(
          '$_endpointUrl/$id',
          data: updateData,
        );
      } catch (_) {
        // Fallback to PATCH if PUT is restricted
        response = await dio.patch(
          '$_endpointUrl/$id',
          data: updateData,
        );
      }

      if (response.statusCode == 200) {
        final updated = VisitorModel.fromJson(response.data as Map<String, dynamic>);
        final idx = _fallbackStorage.indexWhere((v) => v.id == id);
        if (idx != -1) _fallbackStorage[idx] = updated;
        await _saveToCache(_fallbackStorage);
        return updated;
      }
      throw ServerException(message: 'Failed to update visit status on server');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException('Unable to connect to REST API. Please check your internet connection.');
    }
    if (error.response?.statusCode == 404) {
      return NotFoundException('Visitor record not found on server.');
    }
    return ServerException(
      message: error.response?.statusMessage ?? error.message ?? 'Server API communication error',
      statusCode: error.response?.statusCode,
    );
  }
}
