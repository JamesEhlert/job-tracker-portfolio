import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/auth_repository.dart';
import '../repositories/job_repository.dart';
import '../models/job_application.dart';
import '../widgets/job_card.dart';
import 'add_job_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controlador para o campo de texto
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = ''; // O texto que estamos buscando

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthRepository>();
    final user = authRepository.currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            // --- HEADER COM DEGRADÊ E BUSCA ---
            Container(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF334155), Color(0xFF475569)], // Slate Gradient
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
                  // Linha 1: Saudação e Foto
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

                  // Linha 2: BARRA DE PESQUISA (NOVA)
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase(); // Atualiza a busca
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Buscar empresa ou cargo...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.6)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.15), // Fundo translúcido
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // Linha 3: TabBar
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

            // --- CORPO DA LISTA (Com Filtro) ---
            Expanded(
              child: TabBarView(
                children: [
                  _JobList(status: 'to_apply', userId: user!.uid, searchQuery: _searchQuery),
                  _JobList(status: 'applied', userId: user.uid, searchQuery: _searchQuery),
                ],
              ),
            ),
          ],
        ),
        
        // FAB (Botão de Adicionar)
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

// Widget da Lista de Vagas (Agora aceita searchQuery)
class _JobList extends StatelessWidget {
  final String status;
  final String userId;
  final String searchQuery; // Parâmetro novo!

  const _JobList({
    required this.status, 
    required this.userId, 
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<JobApplication>>(
      stream: context.read<JobRepository>().getJobsStream(userId: userId, status: status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final jobs = snapshot.data ?? [];

        // --- LÓGICA DE FILTRAGEM ---
        final filteredJobs = jobs.where((job) {
          final company = job.companyName.toLowerCase();
          final role = job.role.toLowerCase();
          // Verifica se o texto digitado existe no nome da empresa OU no cargo
          return company.contains(searchQuery) || role.contains(searchQuery);
        }).toList();

        if (filteredJobs.isEmpty) {
          // Se não tiver nada (ou se o filtro não encontrou nada)
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  searchQuery.isEmpty 
                      ? (status == 'to_apply' ? Icons.dashboard_outlined : Icons.inventory_2_outlined)
                      : Icons.search_off, // Ícone diferente se for busca vazia
                  size: 60,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty
                      ? (status == 'to_apply' ? 'Planejamento vazio' : 'Histórico vazio')
                      : 'Nenhuma vaga encontrada para "$searchQuery"',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: filteredJobs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final job = filteredJobs[index];
            // Usamos o UniqueKey para garantir que o Flutter não confunda os cards ao filtrar
            return JobCard(key: ValueKey(job.id), job: job);
          },
        );
      },
    );
  }
}