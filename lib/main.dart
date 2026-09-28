import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:movie_app/Providers/auth_provider.dart';
import 'package:movie_app/Providers/movie_provider.dart';
import 'package:movie_app/Providers/list_provider.dart';
import 'package:movie_app/Screens/splash_screen.dart';
void main() async {  
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ListProvider>(
          create: (_) => ListProvider(''),
          update: (_, auth, previous) => ListProvider(auth.userId ?? ''),
        ),
      ],
      child: MaterialApp(
        title: 'Movie App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
