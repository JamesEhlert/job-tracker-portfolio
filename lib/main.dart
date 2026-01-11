import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// Função principal que inicia o aplicativo
void main() async {
  // Garante que a ligação com o sistema nativo (Android) esteja pronta antes de tudo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa a conexão com o Google Firebase
  await Firebase.initializeApp();

  // Roda o aplicativo visual
  runApp(const JobTrackerApp());
}

class JobTrackerApp extends StatelessWidget {
  const JobTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Tracker',
      debugShowCheckedModeBanner: false, // Remove a faixa "Debug" do canto
      theme: ThemeData(
        // Configuração de Cores Profissionais (Material 3)
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // Por enquanto, mostraremos apenas uma tela em branco (Scaffold)
      home: const Scaffold(
        body: Center(
          child: Text('Job Tracker Initialized'),
        ),
      ),
    );
  }
}