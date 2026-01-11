import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'repositories/auth_repository.dart';
import 'repositories/job_repository.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const JobTrackerApp());
}

class JobTrackerApp extends StatelessWidget {
  const JobTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider permite injetar vários repositórios de uma vez
    return MultiProvider(
      providers: [
        // Disponibiliza o AuthRepository para todo o app
        Provider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
        // Disponibiliza o JobRepository para todo o app
        Provider<JobRepository>(
          create: (_) => JobRepository(),
        ),
      ],
      child: MaterialApp(
        title: 'Job Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        // AuthWrapper decide qual tela mostrar (Login ou Home)
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Widget que monitora o estado de autenticação em tempo real
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = Provider.of<AuthRepository>(context);

    return StreamBuilder<User?>(
      stream: authRepository.authStateChanges,
      builder: (context, snapshot) {
        // Se estiver carregando (ex: verificando se tem token salvo)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se tem usuário (snapshot.data não é nulo), vai para a Home
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Se não tem usuário, vai para o Login
        return const LoginScreen();
      },
    );
  }
}