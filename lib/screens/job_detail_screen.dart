import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar data e moeda
import '../models/job_application.dart';

class JobDetailScreen extends StatelessWidget {
  final JobApplication job;

  const JobDetailScreen({super.key, required this.job});

  // Função auxiliar para formatar moeda
  String _formatCurrency(double? value) {
    if (value == null) return 'Não informado';
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return format.format(value);
  }

  // Função auxiliar para formatar data
  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Cores baseadas no status
    final isApplied = job.status == 'applied';
    final statusColor = isApplied ? Colors.green : Colors.blue;
    final statusText = isApplied ? 'Candidatura Enviada' : 'A Candidatar';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Vaga'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho: Empresa e Data
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      job.companyName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    job.companyName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    job.role,
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card de Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isApplied ? Icons.check_circle : Icons.schedule, color: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    statusText.toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Informações em Grade
            _buildInfoRow(Icons.work, 'Modelo', job.workModel == 'Remote' ? 'Remoto' : job.workModel),
            const Divider(),
            _buildInfoRow(Icons.attach_money, 'Pretensão Salarial', _formatCurrency(job.salaryExpectation)),
            const Divider(),
            _buildInfoRow(Icons.calendar_today, 'Criado em', _formatDate(job.createdAt)),
            
            const SizedBox(height: 24),

            // Seção: Link
            const Text(
              'Link da Vaga:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                job.linkUrl,
                style: const TextStyle(color: Colors.blue),
              ),
            ),

            const SizedBox(height: 24),

            // Seção: Descrição
            const Text(
              'Descrição / Anotações:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            SelectableText(
              job.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para linhas de informação
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}