import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/job_application.dart';
import '../repositories/job_repository.dart';
import '../repositories/auth_repository.dart';
import 'add_job_screen.dart';

class JobDetailScreen extends StatelessWidget {
  final JobApplication job;

  const JobDetailScreen({super.key, required this.job});

  String _formatCurrency(double? value) {
    if (value == null) return 'Não informado';
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return format.format(value);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Vaga?'),
        content: const Text('Tem certeza? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('EXCLUIR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // CORREÇÃO: Segurança de contexto assíncrono
      if (!context.mounted) return;

      final userId = context.read<AuthRepository>().currentUser?.uid;
      if (userId != null && job.id != null) {
        await context.read<JobRepository>().deleteJob(userId: userId, jobId: job.id!);
        
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaga excluída.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isApplied = job.status == 'applied';

    return Scaffold(
      // CORREÇÃO: background -> surface ou usar cor do scaffold padrão
      backgroundColor: const Color(0xFFF3F4F6), 
      appBar: AppBar(
        title: const Text('Detalhes da Vaga'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddJobScreen(jobToEdit: job))),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      // CORREÇÃO: withOpacity -> withValues
                      boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withValues(alpha: 0.1))],
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      // CORREÇÃO: withOpacity -> withValues
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    job.role,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    job.companyName,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- STATUS ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isApplied ? Colors.green.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isApplied ? Colors.green.shade200 : Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(isApplied ? Icons.check_circle : Icons.hourglass_top, 
                       color: isApplied ? Colors.green : Colors.blue, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STATUS ATUAL',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        ),
                        Text(
                          isApplied ? 'Candidatura Enviada' : 'A Candidatar / Planejamento',
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            color: isApplied ? Colors.green.shade800 : Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- INFORMAÇÕES GERAIS ---
            Card(
              elevation: 0, // Design mais limpo
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.work_outline, 'Modelo de Trabalho', job.workModel == 'Remote' ? 'Remoto' : job.workModel),
                    const Divider(),
                    _buildInfoRow(Icons.monetization_on_outlined, 'Pretensão Salarial', _formatCurrency(job.salaryExpectation)),
                    const Divider(),
                    _buildInfoRow(Icons.calendar_today_outlined, 'Criado em', _formatDate(job.createdAt)),
                    const Divider(),
                    // Link
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.link, color: Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Link da Vaga', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                GestureDetector(
                                  onTap: () {
                                    // Futuro: Url Launcher
                                  },
                                  child: Text(
                                    job.linkUrl.isEmpty ? 'Não informado' : job.linkUrl,
                                    style: TextStyle(color: colorScheme.primary, decoration: TextDecoration.underline),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- DESCRIÇÃO ---
            if (job.description.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Sobre a Vaga', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(job.description, style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.5)),
                ),
              ),
            ],

            // --- GALERIA COM CACHE ---
            if (job.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Galeria de Prints', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: job.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: job.imageUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}