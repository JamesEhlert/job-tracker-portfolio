import 'package:cloud_firestore/cloud_firestore.dart';

/// Classe que representa uma Vaga de Emprego no sistema.
/// 
/// Contém todos os dados necessários para o gerenciamento de candidaturas.
class JobApplication {
  // O ID único do documento no Firebase (nulo antes de salvar)
  final String? id;
  
  // Dados principais da vaga
  final String companyName;
  final String role;
  final String description;
  final double? salaryExpectation;
  
  // Modelo de trabalho: Remote, Hybrid, OnSite
  final String workModel;
  
  // Link para a vaga original e origem (LinkedIn, Indeed, etc)
  final String linkUrl;
  
  // Status da candidatura: 'to_apply', 'applied', 'interview', 'rejected', 'offer'
  final String status;
  
  // Lista de URLs das imagens (prints) salvas no Storage
  final List<String> imageUrls;
  
  // Datas de controle
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Construtor: Define como criar um objeto dessa classe
  JobApplication({
    this.id,
    required this.companyName,
    required this.role,
    required this.description,
    this.salaryExpectation,
    required this.workModel,
    required this.linkUrl,
    required this.status,
    this.imageUrls = const [], // Inicia com lista vazia se não informado
    this.createdAt,
    this.updatedAt,
  });

  /// Converte o objeto Dart para um Mapa (JSON) para salvar no Firebase.
  /// O Firebase não entende objetos Dart, ele entende Mapas 'chave: valor'.
  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'role': role,
      'description': description,
      'salaryExpectation': salaryExpectation,
      'workModel': workModel,
      'linkUrl': linkUrl,
      'status': status,
      'imageUrls': imageUrls,
      // Se a data existir, converte para Timestamp do Firebase, senão salva a data de agora do servidor
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(), // Sempre atualiza a data de modificação
    };
  }

  /// Cria um objeto JobApplication a partir de um documento do Firebase.
  /// Usado quando baixamos os dados da nuvem para mostrar na tela.
  factory JobApplication.fromMap(Map<String, dynamic> map, String documentId) {
    return JobApplication(
      id: documentId,
      companyName: map['companyName'] ?? '', // Se vier nulo, coloca vazio
      role: map['role'] ?? '',
      description: map['description'] ?? '',
      salaryExpectation: map['salaryExpectation']?.toDouble(),
      workModel: map['workModel'] ?? 'Remote',
      linkUrl: map['linkUrl'] ?? '',
      status: map['status'] ?? 'to_apply',
      // Converte a lista dinâmica do Firebase para lista de Strings do Dart
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      // Converte o Timestamp do Firebase de volta para DateTime do Dart
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}