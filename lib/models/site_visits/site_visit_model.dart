// Site Visit Model
import 'inspection_model.dart';

enum SiteVisitStatus {
  pending,
  invoiced,
  converted,
}

extension SiteVisitStatusExtension on SiteVisitStatus {
  String get displayName {
    switch (this) {
      case SiteVisitStatus.pending:
        return 'PENDING';
      case SiteVisitStatus.invoiced:
        return 'INVOICED';
      case SiteVisitStatus.converted:
        return 'CONVERTED';
    }
  }

  String get sinhalaName {
    switch (this) {
      case SiteVisitStatus.pending:
        return 'බලාපොරොත්තුවෙන්';
      case SiteVisitStatus.invoiced:
        return 'ඉන්වොයිස් කළා';
      case SiteVisitStatus.converted:
        return 'පරිවර්තනය කළා';
    }
  }
}

class SiteVisitModel {
  final String id;
  final String customerName;
  final String projectTitle;
  final String contactNo;
  final String location;
  final DateTime date;
  final String siteType;
  final double charge;
  final SiteVisitStatus status;
  final String colorCode;
  final String thickness;
  final List<String> floorCondition;
  final List<String> targetArea;
  final InspectionModel inspection;
  final String? otherDetails;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SiteVisitModel({
    required this.id,
    required this.customerName,
    required this.projectTitle,
    required this.contactNo,
    required this.location,
    required this.date,
    required this.siteType,
    required this.charge,
    required this.status,
    required this.colorCode,
    required this.thickness,
    required this.floorCondition,
    required this.targetArea,
    required this.inspection,
    this.otherDetails,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SiteVisitModel.fromJson(Map<String, dynamic> json) {
    return SiteVisitModel(
      id: json['id'],
      customerName: json['customerName'],
      projectTitle: json['projectTitle'] ?? '',
      contactNo: json['contactNo'],
      location: json['location'],
      date: DateTime.parse(json['date']),
      siteType: json['siteType'],
      charge: (json['charge'] as num).toDouble(),
      status: SiteVisitStatus.values.firstWhere(
        (e) => e.displayName == json['status'],
        orElse: () => SiteVisitStatus.pending,
      ),
      colorCode: json['colorCode'] ?? '',
      thickness: json['thickness'] ?? '',
      floorCondition: List<String>.from(json['floorCondition'] ?? []),
      targetArea: List<String>.from(json['targetArea'] ?? []),
      inspection: InspectionModel.fromJson(json['inspection'] ?? {}),
      otherDetails: json['otherDetails'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'projectTitle': projectTitle,
      'contactNo': contactNo,
      'location': location,
      'date': date.toIso8601String(),
      'siteType': siteType,
      'charge': charge,
      'status': status.displayName,
      'colorCode': colorCode,
      'thickness': thickness,
      'floorCondition': floorCondition,
      'targetArea': targetArea,
      'inspection': inspection.toJson(),
      'otherDetails': otherDetails,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  SiteVisitModel copyWith({
    String? id,
    String? customerName,
    String? projectTitle,
    String? contactNo,
    String? location,
    DateTime? date,
    String? siteType,
    double? charge,
    SiteVisitStatus? status,
    String? colorCode,
    String? thickness,
    List<String>? floorCondition,
    List<String>? targetArea,
    InspectionModel? inspection,
    String? otherDetails,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SiteVisitModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      projectTitle: projectTitle ?? this.projectTitle,
      contactNo: contactNo ?? this.contactNo,
      location: location ?? this.location,
      date: date ?? this.date,
      siteType: siteType ?? this.siteType,
      charge: charge ?? this.charge,
      status: status ?? this.status,
      colorCode: colorCode ?? this.colorCode,
      thickness: thickness ?? this.thickness,
      floorCondition: floorCondition ?? this.floorCondition,
      targetArea: targetArea ?? this.targetArea,
      inspection: inspection ?? this.inspection,
      otherDetails: otherDetails ?? this.otherDetails,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}