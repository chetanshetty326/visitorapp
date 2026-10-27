import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
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

  // In-memory persistent fallback store with realistic seed data
  // Ensures the app functions seamlessly and never crashes if the external mock API is unreachable or not yet configured.
  static final List<VisitorModel> _mockStorage = [
    VisitorModel(
      id: 'VIS001',
      name: 'Rahul Sharma',
      mobile: '9876543210',
      email: 'rahul@example.com',
      visitorType: AppConstants.typeCustomer,
      project: AppConstants.projectA,
      purpose: 'Site Visit',
      status: AppConstants.statusRegistered,
      createdAt: DateTime.now(),
      checkInTime: null,
      checkOutTime: null,
    ),
    VisitorModel(
      id: 'VIS002',
      name: 'Priya Patel',
      mobile: '9876543211',
      email: 'priya@example.com',
      visitorType: AppConstants.typeVendor,
      project: AppConstants.projectB,
      purpose: 'Material Delivery',
      status: AppConstants.statusCheckedIn,
      createdAt: DateTime.now(),
      checkInTime: DateTime.now().subtract(const Duration(minutes: 45)),
      checkOutTime: null,
    ),
    VisitorModel(
      id: 'VIS003',
      name: 'Amit Kumar',
      mobile: '9876543212',
      email: 'amit@example.com',
      visitorType: AppConstants.typeCustomer,
      project: AppConstants.projectC,
      purpose: 'Flat Inspection',
      status: AppConstants.statusCheckedOut,
      createdAt: DateTime.now(),
      checkInTime: DateTime.now().subtract(const Duration(hours: 3)),
      checkOutTime: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  VisitorRemoteDataSourceImpl({required this.dio});

  bool get _isDefaultMockUrl => ApiConstants.baseUrl == ApiConstants.defaultBaseUrl;

  @override
  Future<List<VisitorModel>> getVisitors() async {
    // If user configured their live mock URL, query it via Dio
    if (!_isDefaultMockUrl) {
      try {
        final response = await dio.get('${ApiConstants.baseUrl}${ApiConstants.visitorsEndpoint}');
        if (response.statusCode == 200 && response.data is List) {
          return (response.data as List)
              .map((e) => VisitorModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } on DioException catch (e) {
        throw _handleDioError(e);
      }
    }

    // Default mock store with persistent lifecycle
    await Future.delayed(const Duration(milliseconds: 300));
    return List<VisitorModel>.from(_mockStorage);
  }

  @override
  Future<VisitorModel> getVisitorById(String id) async {
    if (!_isDefaultMockUrl) {
      try {
        final response =
            await dio.get('${ApiConstants.baseUrl}${ApiConstants.visitorsEndpoint}/$id');
        if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
          return VisitorModel.fromJson(response.data as Map<String, dynamic>);
        } else {
          throw NotFoundException('Visitor with ID $id not found');
        }
      } on DioException catch (e) {
        throw _handleDioError(e);
      }
    }

    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockStorage.indexWhere((v) => v.id == id);
    if (index == -1) {
      throw NotFoundException('Visitor with ID $id not found');
    }
    return _mockStorage[index];
  }

  @override
  Future<VisitorModel> registerVisitor(VisitorModel visitor) async {
    final generatedId = 'VIS${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final newVisitor = VisitorModel(
      id: generatedId,
      name: visitor.name,
      mobile: visitor.mobile,
      email: visitor.email,
      visitorType: visitor.visitorType,
      project: visitor.project,
      purpose: visitor.purpose,
      status: AppConstants.statusRegistered,
      createdAt: DateTime.now(),
      checkInTime: null,
      checkOutTime: null,
    );

    if (!_isDefaultMockUrl) {
      try {
        final response = await dio.post(
          '${ApiConstants.baseUrl}${ApiConstants.visitorsEndpoint}',
          data: newVisitor.toJson(includeId: false),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          return VisitorModel.fromJson(response.data as Map<String, dynamic>);
        }
      } on DioException catch (e) {
        throw _handleDioError(e);
      }
    }

    await Future.delayed(const Duration(milliseconds: 400));
    _mockStorage.insert(0, newVisitor);
    return newVisitor;
  }

  @override
  Future<VisitorModel> updateVisitor(VisitorModel visitor) async {
    if (!_isDefaultMockUrl) {
      try {
        final response = await dio.put(
          '${ApiConstants.baseUrl}${ApiConstants.visitorsEndpoint}/${visitor.id}',
          data: visitor.toJson(),
        );
        if (response.statusCode == 200) {
          return VisitorModel.fromJson(response.data as Map<String, dynamic>);
        }
      } on DioException catch (e) {
        throw _handleDioError(e);
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockStorage.indexWhere((v) => v.id == visitor.id);
    if (index == -1) {
      throw NotFoundException('Visitor with ID ${visitor.id} not found');
    }
    _mockStorage[index] = visitor;
    return visitor;
  }

  @override
  Future<void> deleteVisitor(String id) async {
    if (!_isDefaultMockUrl) {
      try {
        final response =
            await dio.delete('${ApiConstants.baseUrl}${ApiConstants.visitorsEndpoint}/$id');
        if (response.statusCode == 200 || response.statusCode == 204) {
          return;
        }
      } on DioException catch (e) {
        throw _handleDioError(e);
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockStorage.indexWhere((v) => v.id == id);
    if (index == -1) {
      throw NotFoundException('Visitor with ID $id not found');
    }
    _mockStorage.removeAt(index);
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

    if (!_isDefaultMockUrl) {
      try {
        final response = await dio.patch(
          '${ApiConstants.baseUrl}${ApiConstants.visitorsEndpoint}/$id',
          data: updateData,
        );
        if (response.statusCode == 200) {
          return VisitorModel.fromJson(response.data as Map<String, dynamic>);
        }
      } on DioException catch (e) {
        throw _handleDioError(e);
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockStorage.indexWhere((v) => v.id == id);
    if (index == -1) {
      throw NotFoundException('Visitor with ID $id not found');
    }

    final current = _mockStorage[index];
    final updated = VisitorModel(
      id: current.id,
      name: current.name,
      mobile: current.mobile,
      email: current.email,
      visitorType: current.visitorType,
      project: current.project,
      purpose: current.purpose,
      status: status,
      createdAt: current.createdAt,
      checkInTime: checkInTime ?? current.checkInTime,
      checkOutTime: checkOutTime ?? current.checkOutTime,
    );
    _mockStorage[index] = updated;
    return updated;
  }

  Exception _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException('Unable to reach server. Please check connection.');
    }
    if (error.response?.statusCode == 404) {
      return NotFoundException('Visitor record not found on server.');
    }
    return ServerException(
      message: error.response?.statusMessage ?? error.message ?? 'Unknown API error',
      statusCode: error.response?.statusCode,
    );
  }
}
