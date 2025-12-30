// Inspection Model
class InspectionModel {
  final String skirting;
  final String floorPreparation;
  final String groundSetting;
  final String door;
  final String window;
  final String evenUneven;
  final String areaCondition;

  InspectionModel({
    this.skirting = '',
    this.floorPreparation = '',
    this.groundSetting = '',
    this.door = '',
    this.window = '',
    this.evenUneven = '',
    this.areaCondition = '',
  });

  factory InspectionModel.fromJson(Map<String, dynamic> json) {
    return InspectionModel(
      skirting: json['skirting'] ?? '',
      floorPreparation: json['floorPreparation'] ?? '',
      groundSetting: json['groundSetting'] ?? '',
      door: json['door'] ?? '',
      window: json['window'] ?? '',
      evenUneven: json['evenUneven'] ?? '',
      areaCondition: json['areaCondition'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skirting': skirting,
      'floorPreparation': floorPreparation,
      'groundSetting': groundSetting,
      'door': door,
      'window': window,
      'evenUneven': evenUneven,
      'areaCondition': areaCondition,
    };
  }

  InspectionModel copyWith({
    String? skirting,
    String? floorPreparation,
    String? groundSetting,
    String? door,
    String? window,
    String? evenUneven,
    String? areaCondition,
  }) {
    return InspectionModel(
      skirting: skirting ?? this.skirting,
      floorPreparation: floorPreparation ?? this.floorPreparation,
      groundSetting: groundSetting ?? this.groundSetting,
      door: door ?? this.door,
      window: window ?? this.window,
      evenUneven: evenUneven ?? this.evenUneven,
      areaCondition: areaCondition ?? this.areaCondition,
    );
  }
}