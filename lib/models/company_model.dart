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
}