/// Base interface for all business documents
abstract class BaseDocument {
  String get id;
  String get displayId;
  String get customerName;
  String get customerPhone;
  String get projectTitle;
  DateTime get date;
  String get status;
  double get totalAmount;
}

/// Extension methods for common document operations
extension DocumentExtensions on BaseDocument {
  bool get isDraft => status.toLowerCase() == 'draft';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isCompleted => status.toLowerCase() == 'completed' || status.toLowerCase() == 'paid';

  String get statusDisplay => status[0].toUpperCase() + status.substring(1).toLowerCase();
}
