class UrlContainer {
  static const String domainUrl = 'https://smmartcrm.in';
  static const String baseUrl = '$domainUrl/flutex_admin_api/';
  static const String downloadUrl = '$domainUrl/download/file';
  static const String uploadPath = 'uploads';
  static const String limit = '10';
  static const String ticketAttachmentUrl =
      '$domainUrl/download/preview_image?path=$uploadPath/ticket_attachments/';

  static RegExp emailValidatorRegExp = RegExp(
    r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  // Authentication
  static const String loginUrl = 'auth/login';
  static const String tokenUrl = 'auth/firebase-token';
  static const String logoutUrl = 'auth/logout';
  static const String forgotPasswordUrl = 'auth/forgot-password';

  // Pages
  static const String overviewUrl = 'overview';
  static const String dashboardUrl = 'dashboard';
  static const String profileUrl = 'profile';
  static const String customersUrl = 'customers';
  static const String contactsUrl = 'contacts';
  static const String projectsUrl = 'projects';
  static const String invoicesUrl = 'invoices';
  static const String contractsUrl = 'contracts';
  static const String estimatesUrl = 'estimates';
  static const String proposalsUrl = 'proposals';
  static const String ticketsUrl = 'tickets';
  static const String leadsUrl = 'leads';
  static const String kanbanLeadsUrl = 'kanban_leads';
  static const String tasksUrl = 'tasks';
  static const String paymentsUrl = 'payments';
  static const String itemsUrl = 'items';
  static const String notificationsUrl = 'notifications';
  static const String staffsUrl = 'staffs';
  static const String expensesUrl = 'expenses';
  static const String miscellaneousUrl = 'miscellaneous';
  static const String privacyPolicyUrl = 'miscellaneous/privacy';

  // Sales Tracker
  static const String salesTrackerGetLeadsUrl = 'sales-tracker/get-leads';
  static const String salesTrackerSearchLeadUrl = 'sales-tracker/search-lead';
  static const String salesTrackerStartTripUrl = 'sales-tracker/start-trip';
  static const String salesTrackerGetActiveTripUrl =
      'sales-tracker/get-active-trip';
  static const String salesTrackerReachedUrl = 'sales-tracker/reached';
  static const String salesTrackerUpdateAddressUrl =
      'sales-tracker/update-address';
  static const String salesTrackerCallStartUrl = 'sales-tracker/call-start';
  static const String salesTrackerEndTripUrl = 'sales-tracker/end-trip';
  static const String salesTrackerGetStatusUrl = 'sales-tracker/get-status';

  // Download URLs
  static const String leadAttachmentUrl = '$downloadUrl/lead_attachment';
  static const String salesAttachmentUrl = '$downloadUrl/sales_attachment';
}
