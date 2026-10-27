import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../entities/dashboard_stats.dart';
import '../entities/visitor.dart';

class GetDashboardStatsUseCase {
  DashboardStats call(List<Visitor> visitors) {
    int totalVisitorsToday = 0;
    int currentlyCheckedIn = 0;
    int checkedOutToday = 0;

    for (final visitor in visitors) {
      // Total Visitors Today: Registered today (based on local date of created_at)
      if (DateFormatter.isToday(visitor.createdAt)) {
        totalVisitorsToday++;
      }

      // Currently Checked In: Visitors whose current status is Checked In
      if (visitor.status == AppConstants.statusCheckedIn) {
        currentlyCheckedIn++;
      }

      // Checked Out Today: Visitors checked out today (based on check_out_time isToday, or status + created_at)
      if (visitor.status == AppConstants.statusCheckedOut) {
        if (visitor.checkOutTime != null) {
          if (DateFormatter.isToday(visitor.checkOutTime)) {
            checkedOutToday++;
          }
        } else if (DateFormatter.isToday(visitor.createdAt)) {
          checkedOutToday++;
        }
      }
    }

    return DashboardStats(
      totalVisitorsToday: totalVisitorsToday,
      currentlyCheckedIn: currentlyCheckedIn,
      checkedOutToday: checkedOutToday,
    );
  }
}
