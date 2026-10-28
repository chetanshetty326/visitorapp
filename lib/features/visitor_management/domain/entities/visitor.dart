import 'package:equatable/equatable.dart';

class Visitor extends Equatable {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String visitorType; 
  final String project;    
  final String purpose;
  final String status;      
  final DateTime createdAt;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  const Visitor({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
    required this.status,
    required this.createdAt,
    this.checkInTime,
    this.checkOutTime,
  });

  Visitor copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? visitorType,
    String? project,
    String? purpose,
    String? status,
    DateTime? createdAt,
    DateTime? checkInTime,
    DateTime? checkOutTime,
  }) {
    return Visitor(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      visitorType: visitorType ?? this.visitorType,
      project: project ?? this.project,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
    );
  }

  bool get isRegistered => status == 'Registered';
  bool get isCheckedIn => status == 'Checked In';
  bool get isCheckedOut => status == 'Checked Out';

  @override
  List<Object?> get props => [
        id,
        name,
        mobile,
        email,
        visitorType,
        project,
        purpose,
        status,
        createdAt,
        checkInTime,
        checkOutTime,
      ];
}
