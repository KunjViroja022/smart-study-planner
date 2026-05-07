import 'package:flutter/material.dart';
import 'app.dart';
import 'services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize offline storage
  await HiveService.init();
  
  runApp(const SmartStudyApp());
}
