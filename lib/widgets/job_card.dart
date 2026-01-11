import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/job_application.dart';
import '../repositories/job_repository.dart';
import '../repositories/auth_repository.dart';
import '../screens/job_detail_screen.dart';
import '../screens/add_job_screen.dart';

class JobCard extends StatelessWidget {
  final JobApplication job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final isToApply = job.status == 'to_apply';
    
    // Cores Pastéis (Opacas) para os Badges
    Color badgeBg;
    Color badgeText;
    
    if (job.workModel == 'Remote') {
      badgeBg = const Color(0xFFF3E8FF); // Roxo muito claro
      badgeText = const Color(0xFF7E22CE); // Roxo médio
    } else if (job.workModel == 'Hybrid') {
      badgeBg = const Color(0xFFFFF7ED); // Laranja muito claro
      badgeText = const Color(0xFFC2410C); // Laranja médio
    } else {
      badgeBg = const Color(0xFFEFF6FF); // Azul muito claro
      badgeText = const Color(0xFF1D4ED8); // Azul médio
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
            );
          },
          child: Column(
            children: [
              // --- IMAGEM E HEADER ---
              Stack(
                children: [
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: job.imageUrls.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: job.imageUrls.first,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey.shade100,
                              child: Center(
                                child: Icon(Icons.apartment, size: 40, color: Colors.grey.shade300),
                              ),
                            ),
                    ),
                  ),

                  // Badge de Modelo (CORRIGIDO: Agora usa as cores variáveis)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg.withValues(alpha: 0.95), // Usa a cor calculada
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: badgeBg),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.work_outline, size: 12, color: badgeText),
                          const SizedBox(width: 4),
                          Text(
                            job.workModel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeText, // Usa a cor calculada
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Menu 3 Pontos
                  Positioned(
                    top: 0,
                    right: 0,
                    child: PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_horiz, size: 16, color: Colors.white),
                      ),
                      onSelected: (value) => _handleMenuAction(context, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                        const PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                ],
              ),

              // --- CONTEÚDO ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.role,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.companyName,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                    
                    const SizedBox(height: 16),

                    if (isToApply) ...{
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _markAsApplied(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            foregroundColor: const Color(0xFF334155),
                          ),
                          child: const Text('Marcar como Enviado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      )
                    } else ...{
                       Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Candidatura Enviada',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
                          ),
                        ),
                      ),
                    }
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value) {
    if (value == 'edit') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddJobScreen(jobToEdit: job)));
    } else if (value == 'delete') {
      _confirmDelete(context);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir?'),
        content: const Text('Deseja realmente apagar esta vaga?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final userId = context.read<AuthRepository>().currentUser?.uid;
      if (userId != null && job.id != null) {
        await context.read<JobRepository>().deleteJob(userId: userId, jobId: job.id!);
      }
    }
  }

  Future<void> _markAsApplied(BuildContext context) async {
    final userId = context.read<AuthRepository>().currentUser?.uid;
    if (userId == null) return;
    
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
      status: 'applied',
      updatedAt: DateTime.now(),
    );

    await context.read<JobRepository>().updateJob(userId: userId, job: updatedJob);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaga movida para o Histórico.')));
    }
  }
}