abstract class DashboardEvent {}

class LoadDashboardData extends DashboardEvent {
  final int userId;
  LoadDashboardData(this.userId);
}
