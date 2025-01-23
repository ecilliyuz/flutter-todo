import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/todo_viewmodel.dart';
import 'views/todo_list_view.dart';
import 'services/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tüm debug loglarını kapat
  if (kDebugMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoViewModel(),
      child: MaterialApp(
        title: 'Todo Uygulaması',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const TodoListView(),
      ),
    );
  }
}
