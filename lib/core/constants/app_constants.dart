class AppConstants {
  static const String appName = 'Sumadhura Visitor App';

  // Visitor Statuses
  static const String statusRegistered = 'Registered';
  static const String statusCheckedIn = 'Checked In';
  static const String statusCheckedOut = 'Checked Out';

  static const List<String> visitorStatuses = [
    statusRegistered,
    statusCheckedIn,
    statusCheckedOut,
  ];

  // Visitor Types
  static const String typeCustomer = 'Customer';
  static const String typeVendor = 'Vendor';
  static const String typeOther = 'Other';

  static const List<String> visitorTypes = [
    typeCustomer,
    typeVendor,
    typeOther,
  ];

  // Projects
  static const String projectA = 'Project A';
  static const String projectB = 'Project B';
  static const String projectC = 'Project C';

  static const List<String> projects = [
    projectA,
    projectB,
    projectC,
  ];
}
