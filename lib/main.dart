import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'home_screen.dart';
import 'store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: C.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await Store.init();
  await Bank.load();
  runApp(const PravaApp());
}

class PravaApp extends StatelessWidget {
  const PravaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Prava Test UZ',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const HomeScreen(),
      );
}
