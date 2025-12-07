// lib/models/company_model.dart

class CompanyModel {
  final String id;
  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String ownerName;
  final String ownerEmail;
  final String ownerPhone;
  final bool isActive;
  final DateTime createdAt;

  CompanyModel({
    required this.id,
    required this.companyName,
    required this.companyAddress,
    required this.companyPhone,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerPhone,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CompanyModel.empty() => CompanyModel(
        id: '',
        companyName: '',
        companyAddress: '',
        companyPhone: '',
        ownerName: '',
        ownerEmail: '',
        ownerPhone: '',
      );

  // ═══════════════════════════════════════
  // 📝 COPY WITH (for updates)
  // ═══════════════════════════════════════
  CompanyModel copyWith({
    String? id,
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? ownerName,
    String? ownerEmail,
    String? ownerPhone,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhone: companyPhone ?? this.companyPhone,
      ownerName: ownerName ?? this.ownerName,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ═══════════════════════════════════════
  // 🔄 TO/FROM JSON (for Firestore)
  // ═══════════════════════════════════════
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyPhone': companyPhone,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'ownerPhone': ownerPhone,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] ?? '',
      companyName: json['companyName'] ?? '',
      companyAddress: json['companyAddress'] ?? '',
      companyPhone: json['companyPhone'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      ownerPhone: json['ownerPhone'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}