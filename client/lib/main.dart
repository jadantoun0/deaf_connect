import 'package:camera/camera.dart';
import 'package:deafconnect/providers/shortcuts.provider.dart';
import 'package:deafconnect/providers/store.provider.dart';
import 'package:deafconnect/providers/transcript.provider.dart';
import 'package:deafconnect/screens/splash_screen.screen.dart';
import 'package:deafconnect/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

List<CameraDescription> cameras = [];
String flaskUrl = 'http://192.168.1.5:5000/predict';

void main() async {
  // Preventing Landscape Mode
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  cameras = await availableCameras();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TranscriptProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => ShortcutsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage('assets/logo/logo.png'), context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DeafConnect',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(primary: mainColor),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: Colors.transparent),
        appBarTheme: const AppBarTheme(
          backgroundColor: mainColor,
          scrolledUnderElevation: 0,
          foregroundColor: whiteColor,
          centerTitle: true,
          toolbarHeight: 65,
          titleTextStyle: TextStyle(fontSize: 20),
        ),
        dialogTheme: DialogTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodySmall: TextStyle(letterSpacing: 0.1),
          bodyMedium: TextStyle(letterSpacing: 0.1),
          bodyLarge: TextStyle(letterSpacing: 0.1),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
