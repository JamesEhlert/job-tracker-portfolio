import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/job_application.dart';
import '../repositories/job_repository.dart';
import '../repositories/auth_repository.dart';

class AddJobScreen extends StatefulWidget {
  final JobApplication? jobToEdit;

  const AddJobScreen({super.key, this.jobToEdit});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _companyController;
  late TextEditingController _roleController;
  late TextEditingController _descriptionController;
  late TextEditingController _linkController;
  late TextEditingController _salaryController;

  String _status = 'to_apply';
  String _workModel = 'Remote';

  // Correção: Adicionado 'final' conforme pedido pelo log
  final List<String> _existingImageUrls = []; 
  final List<File> _newImages = []; 

  @override
  void initState() {
    super.initState();
    final job = widget.jobToEdit;
    
    _companyController = TextEditingController(text: job?.companyName ?? '');
    _roleController = TextEditingController(text: job?.role ?? '');
    _descriptionController = TextEditingController(text: job?.description ?? '');
    _linkController = TextEditingController(text: job?.linkUrl ?? '');
    _salaryController = TextEditingController(
      text: job?.salaryExpectation?.toString().replaceAll('.', ',') ?? '',
    );

    if (job != null) {
      _status = job.status;
      _workModel = job.workModel;
      _existingImageUrls.addAll(job.imageUrls);
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      setState(() {
        _newImages.addAll(images.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = context.read<AuthRepository>().currentUser?.uid;
      if (userId == null) throw Exception('Usuário não identificado');
      final jobRepo = context.read<JobRepository>();

      List<String> finalImageUrls = [..._existingImageUrls];
      
      for (var imageFile in _newImages) {
        final String url = await jobRepo.uploadImage(
          userId: userId,
          imageFile: imageFile,
        );
        finalImageUrls.add(url);
      }

      final jobData = JobApplication(
        id: widget.jobToEdit?.id,
        companyName: _companyController.text.trim(),
        role: _roleController.text.trim(),
        description: _descriptionController.text.trim(),
        linkUrl: _linkController.text.trim(),
        workModel: _workModel,
        status: _status,
        salaryExpectation: double.tryParse(_salaryController.text.replaceAll(',', '.')),
        imageUrls: finalImageUrls,
        createdAt: widget.jobToEdit?.createdAt ?? DateTime.now(),
      );

      if (widget.jobToEdit != null) {
        await jobRepo.updateJob(userId: userId, job: jobData);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaga atualizada!')));
      } else {
        await jobRepo.addJob(userId: userId, job: jobData);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaga criada!')));
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.jobToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Vaga' : 'Nova Vaga'),
        backgroundColor: const Color(0xFF4F46E5), // AppBar com cor sólida aqui
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Empresa', prefixIcon: Icon(Icons.business)),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Cargo', prefixIcon: Icon(Icons.work)),
                validator: (v) => v!.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      // CORREÇÃO: Usando initialValue em vez de value
                      initialValue: _workModel,
                      decoration: const InputDecoration(labelText: 'Modelo'),
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
                      // CORREÇÃO: Usando initialValue em vez de value
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
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
              TextFormField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Salário', prefixIcon: Icon(Icons.attach_money)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(labelText: 'Link', prefixIcon: Icon(Icons.link)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Imagens / Prints', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Adicionar'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._existingImageUrls.map((url) => _buildImageItem(
                      imageProvider: NetworkImage(url),
                      onRemove: () => setState(() => _existingImageUrls.remove(url)),
                      isNetwork: true,
                    )),
                    ..._newImages.map((file) => _buildImageItem(
                      imageProvider: FileImage(file),
                      onRemove: () => setState(() => _newImages.remove(file)),
                      isNetwork: false,
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _saveJob,
                        child: Text(isEditing ? 'SALVAR ALTERAÇÕES' : 'CRIAR VAGA'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem({required ImageProvider imageProvider, required VoidCallback onRemove, required bool isNetwork}) {
    return Stack(
      children: [
        Container(
          width: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 0,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}