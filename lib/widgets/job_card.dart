import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_application.dart';
import '../repositories/job_repository.dart';
import '../repositories/auth_repository.dart';

class JobCard extends StatelessWidget {
  final JobApplication job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // Cores baseadas no status
    final isToApply = job.status == 'to_apply';
    final cardColor = isToApply ? Colors.white : Colors.green.shade50;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: Empresa e Data
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
                // Ícone de menu para Opções (Editar/Excluir - Futuro)
                const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
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
            
            // Modelo de trabalho (Badge)
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
            
            // Botão de Ação (Apenas se ainda não aplicou)
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
    );
  }

  // Função que move a vaga de uma lista para outra
  Future<void> _markAsApplied(BuildContext context) async {
    final userId = context.read<AuthRepository>().currentUser?.uid;
    if (userId == null) return;

    // Cria uma cópia da vaga atualizando apenas o status e a data
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
      status: 'applied', // MUDANÇA AQUI
      updatedAt: DateTime.now(), // Atualiza a data
    );

    // Envia para o Firebase
    await context.read<JobRepository>().updateJob(
          userId: userId,
          job: updatedJob,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Parabéns! Vaga movida para o Histórico.')),
    );
  }
}