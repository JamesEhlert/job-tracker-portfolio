import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_application.dart';
import '../repositories/job_repository.dart';
import '../repositories/auth_repository.dart';
import '../screens/job_detail_screen.dart'; // Importante: Importa a tela de detalhes

class JobCard extends StatelessWidget {
  final JobApplication job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // Define as cores baseadas no status da vaga
    final isToApply = job.status == 'to_apply';
    final cardColor = isToApply ? Colors.white : Colors.green.shade50;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardColor,
      // Garante que a animação de clique respeite as bordas arredondadas do Card
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // Ação de clique: Navega para a tela de Detalhes
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(job: job),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho: Empresa e Seta indicando que é clicável
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.companyName.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 4),

              // Título: Cargo
              Text(
                job.role,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // Badge: Modelo de trabalho (Remoto, Híbrido, etc)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  job.workModel,
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                ),
              ),

              const SizedBox(height: 12),

              // Botão de Ação: "Marcar como Enviado"
              // Só aparece se a vaga ainda estiver no planejamento ("to_apply")
              if (isToApply)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _markAsApplied(context),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('MARCAR COMO ENVIADO'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Função lógica: Move a vaga da aba "Planejamento" para "Histórico"
  Future<void> _markAsApplied(BuildContext context) async {
    final userId = context.read<AuthRepository>().currentUser?.uid;
    if (userId == null) return;

    // Cria uma cópia da vaga alterando o status para 'applied' e atualizando a data
    final updatedJob = JobApplication(
      id: job.id,
      companyName: job.companyName,
      role: job.role,
      description: job.description,
      salaryExpectation: job.salaryExpectation,
      workModel: job.workModel,
      linkUrl: job.linkUrl,
      imageUrls: job.imageUrls,
      createdAt: job.createdAt,
      status: 'applied', // Mudança de status
      updatedAt: DateTime.now(),
    );

    // Salva a alteração no Firebase
    await context.read<JobRepository>().updateJob(
          userId: userId,
          job: updatedJob,
        );

    // Mostra feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Parabéns! Vaga movida para o Histórico.')),
    );
  }
}