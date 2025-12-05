import 'package:flutter/material.dart';
import 'package:tilework/screens/sidebar_screen.dart';

// -----------------------------------------------------------------------------
// ENUMS AND DATA MODELS 
// -----------------------------------------------------------------------------

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desktop Sidebar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home:SidebarScreen() ,
      // SidebarScreen(),
    );
  }
}
