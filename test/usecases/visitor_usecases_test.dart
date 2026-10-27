import 'package:flutter_test/flutter_test.dart';
import 'package:visitorappointment/core/constants/app_constants.dart';
import 'package:visitorappointment/core/error/exceptions.dart';
import 'package:visitorappointment/features/visitor_management/domain/entities/visitor.dart';
import 'package:visitorappointment/features/visitor_management/domain/repositories/visitor_repository.dart';
import 'package:visitorappointment/features/visitor_management/domain/usecases/check_in_visitor_usecase.dart';
import 'package:visitorappointment/features/visitor_management/domain/usecases/check_out_visitor_usecase.dart';
import 'package:visitorappointment/features/visitor_management/domain/usecases/get_dashboard_stats_usecase.dart';

class MockVisitorRepository implements VisitorRepository {
  final Map<String, Visitor> _database = {};

  void seed(Visitor visitor) {
    _database[visitor.id] = visitor;
  }

  @override
  Future<List<Visitor>> getVisitors() async => _database.values.toList();

  @override
  Future<Visitor> getVisitorById(String id) async {
    if (_database.containsKey(id)) return _database[id]!;
    throw NotFoundException('Visitor not found');
  }

  @override
  Future<Visitor> registerVisitor(Visitor visitor) async {
    _database[visitor.id] = visitor;
    return visitor;
  }

  @override
  Future<Visitor> updateVisitor(Visitor visitor) async {
    _database[visitor.id] = visitor;
    return visitor;
  }

  @override
  Future<void> deleteVisitor(String id) async {
    _database.remove(id);
  }

  @override
  Future<Visitor> checkInVisitor(String id) async {
    final v = _database[id]!;
    final updated = v.copyWith(
      status: AppConstants.statusCheckedIn,
      checkInTime: DateTime.now(),
    );
    _database[id] = updated;
    return updated;
  }

  @override
  Future<Visitor> checkOutVisitor(String id) async {
    final v = _database[id]!;
    final updated = v.copyWith(
      status: AppConstants.statusCheckedOut,
      checkOutTime: DateTime.now(),
    );
    _database[id] = updated;
    return updated;
  }
}

void main() {
  late MockVisitorRepository repository;
  late CheckInVisitorUseCase checkInUseCase;
  late CheckOutVisitorUseCase checkOutUseCase;
  late GetDashboardStatsUseCase statsUseCase;

  setUp(() {
    repository = MockVisitorRepository();
    checkInUseCase = CheckInVisitorUseCase(repository);
    checkOutUseCase = CheckOutVisitorUseCase(repository);
    statsUseCase = GetDashboardStatsUseCase();
  });

  group('Check-In / Check-Out Business Rules Tests', () {
    test('Check-in succeeds when status is Registered', () async {
      final visitor = Visitor(
        id: 'VIS_TEST_1',
        name: 'John Doe',
        mobile: '9876543210',
        visitorType: AppConstants.typeCustomer,
        project: AppConstants.projectA,
        purpose: 'Meeting',
        status: AppConstants.statusRegistered,
        createdAt: DateTime.now(),
      );
      repository.seed(visitor);

      final result = await checkInUseCase('VIS_TEST_1');

      expect(result.status, equals(AppConstants.statusCheckedIn));
      expect(result.checkInTime, isNotNull);
    });

    test('Disallow check-in when visitor is already Checked In', () async {
      final visitor = Visitor(
        id: 'VIS_TEST_2',
        name: 'Jane Doe',
        mobile: '9876543211',
        visitorType: AppConstants.typeVendor,
        project: AppConstants.projectB,
        purpose: 'Delivery',
        status: AppConstants.statusCheckedIn,
        createdAt: DateTime.now(),
        checkInTime: DateTime.now(),
      );
      repository.seed(visitor);

      expect(
        () => checkInUseCase('VIS_TEST_2'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Disallow check-in when visitor has already Checked Out', () async {
      final visitor = Visitor(
        id: 'VIS_TEST_3',
        name: 'Alice',
        mobile: '9876543212',
        visitorType: AppConstants.typeCustomer,
        project: AppConstants.projectC,
        purpose: 'Visit',
        status: AppConstants.statusCheckedOut,
        createdAt: DateTime.now(),
        checkInTime: DateTime.now().subtract(const Duration(hours: 2)),
        checkOutTime: DateTime.now().subtract(const Duration(hours: 1)),
      );
      repository.seed(visitor);

      expect(
        () => checkInUseCase('VIS_TEST_3'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Disallow check-out before checking in', () async {
      final visitor = Visitor(
        id: 'VIS_TEST_4',
        name: 'Bob',
        mobile: '9876543213',
        visitorType: AppConstants.typeOther,
        project: AppConstants.projectA,
        purpose: 'Interview',
        status: AppConstants.statusRegistered,
        createdAt: DateTime.now(),
      );
      repository.seed(visitor);

      expect(
        () => checkOutUseCase('VIS_TEST_4'),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Check-out succeeds when status is Checked In', () async {
      final visitor = Visitor(
        id: 'VIS_TEST_5',
        name: 'Charlie',
        mobile: '9876543214',
        visitorType: AppConstants.typeVendor,
        project: AppConstants.projectB,
        purpose: 'Maintenance',
        status: AppConstants.statusCheckedIn,
        createdAt: DateTime.now(),
        checkInTime: DateTime.now().subtract(const Duration(minutes: 30)),
      );
      repository.seed(visitor);

      final result = await checkOutUseCase('VIS_TEST_5');

      expect(result.status, equals(AppConstants.statusCheckedOut));
      expect(result.checkOutTime, isNotNull);
    });
  });

  group('Dashboard Stats Calculation Tests', () {
    test('Calculates metrics correctly based on local date', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final visitors = [
        // Registered today, still registered
        Visitor(
          id: '1',
          name: 'V1',
          mobile: '9876543210',
          visitorType: AppConstants.typeCustomer,
          project: AppConstants.projectA,
          purpose: 'Visit',
          status: AppConstants.statusRegistered,
          createdAt: now,
        ),
        // Registered today, currently checked in
        Visitor(
          id: '2',
          name: 'V2',
          mobile: '9876543211',
          visitorType: AppConstants.typeCustomer,
          project: AppConstants.projectB,
          purpose: 'Meeting',
          status: AppConstants.statusCheckedIn,
          createdAt: now,
          checkInTime: now,
        ),
        // Registered yesterday, currently checked in (e.g. overnight)
        Visitor(
          id: '3',
          name: 'V3',
          mobile: '9876543212',
          visitorType: AppConstants.typeVendor,
          project: AppConstants.projectA,
          purpose: 'Night shift',
          status: AppConstants.statusCheckedIn,
          createdAt: yesterday,
          checkInTime: yesterday,
        ),
        // Registered today, checked out today
        Visitor(
          id: '4',
          name: 'V4',
          mobile: '9876543213',
          visitorType: AppConstants.typeCustomer,
          project: AppConstants.projectC,
          purpose: 'Inspection',
          status: AppConstants.statusCheckedOut,
          createdAt: now,
          checkInTime: now.subtract(const Duration(hours: 2)),
          checkOutTime: now.subtract(const Duration(hours: 1)),
        ),
        // Registered yesterday, checked out yesterday
        Visitor(
          id: '5',
          name: 'V5',
          mobile: '9876543214',
          visitorType: AppConstants.typeOther,
          project: AppConstants.projectB,
          purpose: 'Old Visit',
          status: AppConstants.statusCheckedOut,
          createdAt: yesterday,
          checkInTime: yesterday,
          checkOutTime: yesterday,
        ),
      ];

      final stats = statsUseCase(visitors);

      // Total visitors registered today: V1, V2, V4 = 3
      expect(stats.totalVisitorsToday, equals(3));
      // Currently checked in: V2, V3 = 2
      expect(stats.currentlyCheckedIn, equals(2));
      // Checked out today: V4 = 1
      expect(stats.checkedOutToday, equals(1));
    });
  });
}
