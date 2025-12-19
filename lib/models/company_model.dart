// ═══════════════════════════════════════
// 🏢 COMPANY MODEL (Main API Model)
// ═══════════════════════════════════════

class CompanyModel {
  final String id;
  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String ownerName;
  final String ownerEmail;
  final String ownerPhone;
  final bool isActive;

  CompanyModel({
    required this.id,
    required this.companyName,
    required this.companyAddress,
    required this.companyPhone,
    required this.ownerName,
    required this.ownerEmail,
    required this.ownerPhone,
    required this.isActive,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['_id'] ?? json['id'] ?? '',
      companyName: json['companyName'] ?? '',
      companyAddress: json['companyAddress'] ?? '',
      companyPhone: json['companyPhone'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      ownerPhone: json['ownerPhone'] ?? '',
      isActive: json['isActive'] ?? true, // Default to true if not specified
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id, // When sending data to backend, use _id or id
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyPhone': companyPhone,
      'ownerName': ownerName,
      'ownerEmail': ownerEmail,
      'ownerPhone': ownerPhone,
      'isActive': isActive,
    };
  }

  CompanyModel copyWith({
    String? id,
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? ownerName,
    String? ownerEmail,
    String? ownerPhone,
    bool? isActive,
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
    );
  }

  factory CompanyModel.empty() => CompanyModel(
        id: '',
        companyName: '',
        companyAddress: '',
        companyPhone: '',
        ownerName: '',
        ownerEmail: '',
        ownerPhone: '',
        isActive: true,
      );
}

// ═══════════════════════════════════════
// 🏢 EXTENDED COMPANY MODEL (For Admin/Super Admin Features)
// ═══════════════════════════════════════

class ExtendedCompanyModel {
  final String id;
  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String ownerName;
  final String ownerEmail;
  final String ownerPhone;
  final bool isActive;
  final DateTime createdAt;

  ExtendedCompanyModel({
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

  factory ExtendedCompanyModel.empty() => ExtendedCompanyModel(
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
  ExtendedCompanyModel copyWith({
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
    return ExtendedCompanyModel(
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

  factory ExtendedCompanyModel.fromJson(Map<String, dynamic> json) {
    return ExtendedCompanyModel(
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
