import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart'; // PACOTE PARA ABRIR LINKS
import '../models/job_application.dart';
import '../repositories/job_repository.dart';
import '../repositories/auth_repository.dart';
import 'add_job_screen.dart';
import 'full_screen_image_screen.dart'; // IMPORT DA NOVA TELA DE IMAGEM

class JobDetailScreen extends StatelessWidget {
  final JobApplication job;

  const JobDetailScreen({super.key, required this.job});

  // Formata moeda (Ex: R$ 5.000,00)
  String _formatCurrency(double? value) {
    if (value == null) return 'Não informado';
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return format.format(value);
  }

  // Formata data (Ex: 10/01/2026 14:30)
  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Lógica para excluir a vaga
  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Vaga?'),
        content: const Text('Tem certeza que deseja apagar esta vaga e todas as imagens? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Cancelar
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Confirmar
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;

      final userId = context.read<AuthRepository>().currentUser?.uid;
      if (userId != null && job.id != null) {
        await context.read<JobRepository>().deleteJob(userId: userId, jobId: job.id!);
        
        // Volta para a tela anterior e avisa
        if (context.mounted) {
          Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vaga excluída com sucesso.')),
          );
        }
      }
    }
  }

  // Lógica para abrir o link no navegador
  Future<void> _launchURL(BuildContext context, String urlString) async {
    if (urlString.isEmpty) return;

    // Garante que o link tenha https:// se o usuário esqueceu
    final String formattedUrl = urlString.startsWith('http') ? urlString : 'https://$urlString';
    final Uri uri = Uri.parse(formattedUrl);

    try {
      // Tenta abrir no navegador externo (Chrome/Safari)
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir este link.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir link: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pega as cores do tema atual (AppTheme)
    final colorScheme = Theme.of(context).colorScheme;
    final isApplied = job.status == 'applied';

    return Scaffold(
      // Usa a cor de fundo definida no tema
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      appBar: AppBar(
        title: const Text('Detalhes da Vaga'),
        actions: [
          // Botão Editar (Lápis)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar Vaga',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddJobScreen(jobToEdit: job),
                ),
              );
            },
          ),
          // Botão Excluir (Lixeira)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Excluir Vaga',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CABEÇALHO (Ícone e Títulos) ---
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 28, 
                          fontWeight: FontWeight.bold, 
                          color: colorScheme.primary
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    job.role,
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.companyName,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- CARD DE STATUS ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Muda a cor do fundo dependendo se já aplicou ou não
                color: isApplied ? Colors.green.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isApplied ? Colors.green.shade200 : Colors.blue.shade200
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isApplied ? Icons.check_circle : Icons.hourglass_top, 
                    color: isApplied ? Colors.green : Colors.blue, 
                    size: 28
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STATUS ATUAL',
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.grey.shade600
                          ),
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

            // --- CARTÃO DE INFORMAÇÕES GERAIS ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.work_outline, 'Modelo de Trabalho', 
                      job.workModel == 'Remote' ? 'Remoto' : 
                      job.workModel == 'Hybrid' ? 'Híbrido' : 'Presencial'
                    ),
                    const Divider(),
                    _buildInfoRow(Icons.monetization_on_outlined, 'Pretensão Salarial', _formatCurrency(job.salaryExpectation)),
                    const Divider(),
                    _buildInfoRow(Icons.calendar_today_outlined, 'Criado em', _formatDate(job.createdAt)),
                    const Divider(),
                    
                    // --- LINK CLICÁVEL ---
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
                                  // Ao clicar, chama a função de abrir navegador
                                  onTap: () => _launchURL(context, job.linkUrl),
                                  child: Text(
                                    job.linkUrl.isEmpty ? 'Não informado' : job.linkUrl,
                                    style: TextStyle(
                                      // Cor primária e sublinhado para indicar que é um link
                                      color: colorScheme.secondary, 
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis,
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

            // --- DESCRIÇÃO / NOTAS ---
            if (job.description.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Sobre a Vaga', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText( // SelectableText permite copiar o texto
                    job.description, 
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.5),
                  ),
                ),
              ),
            ],

            // --- GALERIA DE PRINTS (COM CLIQUE PARA ZOOM) ---
            if (job.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Galeria de Prints', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              SizedBox(
                height: 200, // Altura do carrossel horizontal
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: job.imageUrls.length,
                  itemBuilder: (context, index) {
                    final imageUrl = job.imageUrls[index];
                    
                    // Envolvemos a imagem em um GestureDetector para detectar o toque
                    return GestureDetector(
                      onTap: () {
                        // Navega para a tela cheia ao clicar
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImageScreen(imageUrl: imageUrl),
                          ),
                        );
                      },
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover, // Preenche o quadrado
                            // Loading enquanto baixa
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            // Ícone de erro se falhar
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 40), // Espaço extra no final da tela
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para criar linhas de informação (Ícone + Título + Valor)
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