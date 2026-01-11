import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/job_repository.dart';
import '../models/job_application.dart';
import '../widgets/job_card.dart';
import 'add_job_screen.dart';
// Removido import não utilizado

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    final user = authRepository.currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            // --- HEADER OPACIZADO (Slate Gradient) ---
            Container(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF334155), Color(0xFF475569)], 
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Olá, ${user?.displayName?.split(' ')[0] ?? 'Usuário'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gestão de Carreira',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                          child: user?.photoURL == null ? const Icon(Icons.person) : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // --- TAB BAR MINIMALISTA ---
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      labelColor: const Color(0xFF334155),
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Planejamento'),
                        Tab(text: 'Histórico'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- LISTA ---
            Expanded(
              child: TabBarView(
                children: [
                  _JobList(status: 'to_apply', userId: user!.uid),
                  _JobList(status: 'applied', userId: user.uid),
                ],
              ),
            ),
          ],
        ),
        
        // --- FAB SUAVE ---
        floatingActionButton: SizedBox(
          height: 64,
          width: 64,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddJobScreen()),
              );
            },
            backgroundColor: const Color(0xFF0F766E),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.add, size: 30, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _JobList extends StatelessWidget {
  final String status;
  final String userId;

  const _JobList({required this.status, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<JobApplication>>(
      stream: context.read<JobRepository>().getJobsStream(userId: userId, status: status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final jobs = snapshot.data ?? [];

        if (jobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'to_apply' ? Icons.dashboard_outlined : Icons.inventory_2_outlined,
                  size: 60,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  status == 'to_apply' ? 'Planejamento vazio' : 'Histórico vazio',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: jobs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final job = jobs[index];
            return JobCard(job: job);
          },
        );
      },
    );
  }
}