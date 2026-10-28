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
     
      if (DateFormatter.isToday(visitor.createdAt)) {
        totalVisitorsToday++;
      }

      
      if (visitor.status == AppConstants.statusCheckedIn) {
        currentlyCheckedIn++;
      }

    
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
