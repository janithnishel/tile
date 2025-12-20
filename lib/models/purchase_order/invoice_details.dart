// lib/models/purchase_order/invoice_details.dart

class InvoiceDetails {
  final String? invoiceNumber;
  final DateTime? receivedDate;
  final String? imageUrl;
  final String? imagePath;
  final DateTime? uploadedAt;
  final String? notes;

  InvoiceDetails({
    this.invoiceNumber,
    this.receivedDate,
    this.imageUrl,
    this.imagePath,
    this.uploadedAt,
    this.notes,
  });

  bool get hasInvoice => invoiceNumber != null && invoiceNumber!.isNotEmpty;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  InvoiceDetails copyWith({
    String? invoiceNumber,
    DateTime? receivedDate,
    String? imageUrl,
    String? imagePath,
    DateTime? uploadedAt,
    String? notes,
  }) {
    return InvoiceDetails(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      receivedDate: receivedDate ?? this.receivedDate,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceNumber': invoiceNumber,
      'receivedDate': receivedDate?.toIso8601String(),
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'uploadedAt': uploadedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory InvoiceDetails.fromJson(Map<String, dynamic> json) {
    return InvoiceDetails(
      invoiceNumber: json['invoiceNumber'],
      receivedDate: json['receivedDate'] != null
          ? DateTime.parse(json['receivedDate'])
          : null,
      imageUrl: json['imageUrl'],
      imagePath: json['imagePath'],
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : null,
      notes: json['notes'],
    );
  }

  factory InvoiceDetails.empty() => InvoiceDetails();
}