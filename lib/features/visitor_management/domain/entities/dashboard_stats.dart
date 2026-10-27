import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalVisitorsToday;
  final int currentlyCheckedIn;
  final int checkedOutToday;

  const DashboardStats({
    required this.totalVisitorsToday,
    required this.currentlyCheckedIn,
    required this.checkedOutToday,
  });

  factory DashboardStats.empty() {
    return const DashboardStats(
      totalVisitorsToday: 0,
      currentlyCheckedIn: 0,
      checkedOutToday: 0,
    );
  }

  @override
  List<Object?> get props => [
        totalVisitorsToday,
        currentlyCheckedIn,
        checkedOutToday,
      ];
}
