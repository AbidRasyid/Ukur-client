import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'services/customer_service.dart';
import 'services/settings_service.dart';
import 'widgets/app_theme.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();

    await initializeDateFormatting('id_ID', null);

    await CustomerService.init();
    await SettingsService.init();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppTheme.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    runApp(const UkurClientApp());
  } catch (e, stack) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Text(
                'ERROR:\n\n$e\n\nSTACK:\n\n$stack',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UkurClientApp extends StatelessWidget {
  const UkurClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ukur Client',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
