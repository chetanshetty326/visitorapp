import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/visitor.dart';

class VisitorModel extends Visitor {
  const VisitorModel({
    required super.id,
    required super.name,
    required super.mobile,
    super.email,
    required super.visitorType,
    required super.project,
    required super.purpose,
    required super.status,
    required super.createdAt,
    super.checkInTime,
    super.checkOutTime,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    // Parse createdAt safely
    DateTime createdAt = DateTime.now();
    final rawCreatedAt = json['created_at'] ?? json['createdAt'];
    if (rawCreatedAt != null) {
      final parsed = DateFormatter.parseIso(rawCreatedAt.toString());
      if (parsed != null) createdAt = parsed;
    }

    // Parse checkInTime safely
    final rawCheckIn = json['check_in_time'] ?? json['checkInTime'];
    final checkIn = DateFormatter.parseIso(rawCheckIn?.toString());

    // Parse checkOutTime safely
    final rawCheckOut = json['check_out_time'] ?? json['checkOutTime'];
    final checkOut = DateFormatter.parseIso(rawCheckOut?.toString());

    return VisitorModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      email: json['email']?.toString(),
      visitorType: json['visitor_type']?.toString() ??
          json['visitorType']?.toString() ??
          AppConstants.typeCustomer,
      project: json['project']?.toString() ?? AppConstants.projectA,
      purpose: json['purpose']?.toString() ?? '',
      status: json['status']?.toString() ?? AppConstants.statusRegistered,
      createdAt: createdAt,
      checkInTime: checkIn,
      checkOutTime: checkOut,
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final map = <String, dynamic>{
      'name': name,
      'mobile': mobile,
      'email': email,
      'visitor_type': visitorType,
      'project': project,
      'purpose': purpose,
      'status': status,
      'created_at': DateFormatter.toIso(createdAt),
      'check_in_time': checkInTime != null ? DateFormatter.toIso(checkInTime!) : null,
      'check_out_time': checkOutTime != null ? DateFormatter.toIso(checkOutTime!) : null,
    };
    if (includeId && id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  factory VisitorModel.fromEntity(Visitor entity) {
    return VisitorModel(
      id: entity.id,
      name: entity.name,
      mobile: entity.mobile,
      email: entity.email,
      visitorType: entity.visitorType,
      project: entity.project,
      purpose: entity.purpose,
      status: entity.status,
      createdAt: entity.createdAt,
      checkInTime: entity.checkInTime,
      checkOutTime: entity.checkOutTime,
    );
  }

  Visitor toEntity() {
    return Visitor(
      id: id,
      name: name,
      mobile: mobile,
      email: email,
      visitorType: visitorType,
      project: project,
      purpose: purpose,
      status: status,
      createdAt: createdAt,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
    );
  }
}
