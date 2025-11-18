import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'pages/controllers/task_controller.dart';
import 'pages/controllers/category_controller.dart';
import 'pages/home_page.dart';
import 'pages/services/notification_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // timezone
  tz.initializeTimeZones();

  // service notifikasi
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider(
          create: (_) => TaskController(),
          
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryController(),
        ),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

