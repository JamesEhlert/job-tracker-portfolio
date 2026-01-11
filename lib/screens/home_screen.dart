import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/job_repository.dart';
import '../models/job_application.dart';
import '../widgets/job_card.dart';
import 'add_job_screen.dart';
import 'login_screen.dart'; // Importante para redirecionar no logout

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    final user = authRepository.currentUser;

    // Controlador das Abas (2 abas)
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Job Tracker'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'PLANEJAMENTO', icon: Icon(Icons.list_alt)),
              Tab(text: 'HISTÓRICO', icon: Icon(Icons.history)),
            ],
          ),
          actions: [
            // Menu do Usuário
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'logout') {
                  await authRepository.signOut();
                  // O AuthWrapper no main.dart cuidará da navegação, mas podemos forçar se necessário
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'user',
                  child: Text('Olá, ${user?.displayName?.split(' ')[0] ?? 'Usuário'}'),
                  enabled: false, // Item apenas visual
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 8), Text('Sair')],
                  ),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CircleAvatar(
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null ? const Icon(Icons.person) : null,
                ),
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Aba 1: Vagas 'to_apply' (A Candidatar)
            _JobList(status: 'to_apply', userId: user!.uid),
            
            // Aba 2: Vagas 'applied' (Candidatado)
            _JobList(status: 'applied', userId: user.uid),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddJobScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

// Widget auxiliar para listar as vagas (evita duplicar código)
class _JobList extends StatelessWidget {
  final String status;
  final String userId;

  const _JobList({required this.status, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<JobApplication>>(
      // Chama o repositório pedindo apenas as vagas daquele status
      stream: context.read<JobRepository>().getJobsStream(userId: userId, status: status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        final jobs = snapshot.data ?? [];

        if (jobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  status == 'to_apply' ? 'Nenhuma vaga planejada.' : 'Nenhuma candidatura enviada.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        // Lista de Vagas
        return ListView.builder(
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return JobCard(job: job);
          },
        );
      },
    );
  }
}