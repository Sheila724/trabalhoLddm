import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/home_page.dart';
import 'db/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database; // inicializa o DB
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.light();
    final mono = base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: Colors.black,
        onPrimary: Colors.white,
        background: Colors.white,
        onBackground: Colors.black87,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFFF7F7F7),
        foregroundColor: Colors.black,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
    );

    return MaterialApp(
      title: 'Cadastro de Serviços',
      debugShowCheckedModeBanner: false,
      theme: mono,
      home: const HomePage(),
    );
  }
}
