// Constants
import 'package:flutter/material.dart';

class AppConstants {
  // Company Info
  static const String companyName = 'IMMENSE HOME';
  static const String companySubtitle = 'PRIVATE LIMITED';
  static const String companyAddress1 = '157/1 Old Kottawa Road, Mirihana, Nugegoda';
  static const String companyAddress2 = 'No.23/1, Akurassa Road Nupe, Matara';
  static const String companyCity = 'Colombo 81300, LK';
  static const String companyWebsite = 'www.immensehome.lk';
  static const String companyPhone = '077 586 70 80';
  static const String companyEmail = 'immensehomeprivatelimited@gmail.com';
  
  // Banking Details
  static const String bankName = 'Hatton National Bank';
  static const String accountName = 'Immense Home (Pvt) Ltd';
  static const String accountNumber = '200010008304';

  // Floor Condition Options
  static const List<String> floorConditionOptions = [
    'Cement',
    'Tile',
    'Terrazzo',
    'Titanium',
    'Concrete',
    'Wood',
    'Other',
  ];

  // Target Area Options
  static const List<String> targetAreaOptions = [
    'Living',
    'Hall',
    'Room',
    'Dining',
    'Passage',
    'Kitchen',
    'Other',
  ];

  // Site Types
  static const List<String> siteTypes = [
    'Residential',
    'Commercial',
    'Industrial',
  ];

  // Thickness Options
  static const List<String> thicknessOptions = [
    '6mm',
    '8mm',
    '10mm',
    '12mm',
  ];
}

class AppColors {
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryPurpleDark = Color(0xFF6D28D9);
  static const Color primaryPurpleLight = Color(0xFFEDE9FE);
  
  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenLight = Color(0xFFD1FAE5);
  
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color warningYellowLight = Color(0xFFFEF3C7);
  
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color infoBlueLight = Color(0xFFDBEAFE);
  
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorRedLight = Color(0xFFFEE2E2);
  
  static const Color orangeAccent = Color(0xFFF97316);
  static const Color orangeAccentDark = Color(0xFFEA580C);
}