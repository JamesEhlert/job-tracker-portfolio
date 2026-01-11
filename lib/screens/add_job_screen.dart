import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/job_application.dart';
import '../repositories/job_repository.dart';
import '../repositories/auth_repository.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>(); // Chave para validar o formulário
  bool _isLoading = false;

  // Controladores dos campos de texto
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  final _salaryController = TextEditingController();

  // Valores padrão para os Dropdowns
  String _status = 'to_apply'; // Começa como "A Candidatar"
  String _workModel = 'Remote'; // Começa como "Remoto"

  @override
  void dispose() {
    // Limpa a memória dos controladores quando sair da tela
    _companyController.dispose();
    _roleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  // Função para Salvar a Vaga
  Future<void> _saveJob() async {
    // 1. Verifica se o formulário está válido (campos obrigatórios preenchidos)
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 2. Pega o ID do usuário logado (obrigatório para salvar na pasta certa)
      final userId = context.read<AuthRepository>().currentUser?.uid;
      if (userId == null) throw Exception('Usuário não identificado');

      // 3. Cria o objeto da Vaga com os dados digitados
      final job = JobApplication(
        companyName: _companyController.text.trim(),
        role: _roleController.text.trim(),
        description: _descriptionController.text.trim(),
        linkUrl: _linkController.text.trim(),
        workModel: _workModel,
        status: _status,
        // Converte o texto do salário para número (se tiver texto)
        salaryExpectation: double.tryParse(_salaryController.text.replaceAll(',', '.')),
        imageUrls: [], // Implementaremos imagens na próxima etapa
      );

      // 4. Chama o repositório para enviar ao Firestore
      await context.read<JobRepository>().addJob(
            userId: userId,
            job: job,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vaga salva com sucesso!')),
        );
        Navigator.pop(context); // Fecha a tela e volta para a Home
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Vaga')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Campo: Empresa ---
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Empresa',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // --- Campo: Cargo ---
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Cargo / Vaga',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              // --- Linha: Modelo e Status ---
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _workModel,
                      decoration: const InputDecoration(labelText: 'Modelo', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Remote', child: Text('Remoto')),
                        DropdownMenuItem(value: 'Hybrid', child: Text('Híbrido')),
                        DropdownMenuItem(value: 'OnSite', child: Text('Presencial')),
                      ],
                      onChanged: (v) => setState(() => _workModel = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status Inicial', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'to_apply', child: Text('A Candidatar')),
                        DropdownMenuItem(value: 'applied', child: Text('Já Candidatei')),
                      ],
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Campo: Salário ---
              TextFormField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pretensão Salarial (Opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 16),

              // --- Campo: Link ---
              TextFormField(
                controller: _linkController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Link da Vaga',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Cole o link da vaga' : null,
              ),
              const SizedBox(height: 16),

              // --- Campo: Descrição (Grande) ---
              TextFormField(
                controller: _descriptionController,
                maxLines: 5, // Permite 5 linhas visíveis
                maxLength: 5000, // Limite generoso que definimos
                decoration: const InputDecoration(
                  labelText: 'Descrição da Vaga / Anotações',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // --- Botão Salvar ---
              SizedBox(
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveJob,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('SALVAR VAGA', style: TextStyle(fontSize: 16)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}