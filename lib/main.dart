import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'repositories/auth_repository.dart';
import 'repositories/job_repository.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart'; // <--- IMPORTANTE: Importar o arquivo gerado

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // AQUI ESTÁ A CORREÇÃO MÁGICA PARA WEB
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // <--- Isso escolhe a chave certa (Web ou Android) automaticamente
  );
  
  runApp(const JobTrackerApp());
}

class JobTrackerApp extends StatelessWidget {
  const JobTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<JobRepository>(create: (_) => JobRepository()),
      ],
      child: MaterialApp(
        title: 'Job Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = Provider.of<AuthRepository>(context);
    return StreamBuilder<User?>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) return const HomeScreen();
        return const LoginScreen();
      },
    );
  }
}