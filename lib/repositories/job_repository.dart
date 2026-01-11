import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_application.dart';

/// Repositório responsável pelas operações de banco de dados (CRUD) das vagas.
class JobRepository {
  final FirebaseFirestore _firestore;

  JobRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Cria uma referência para a coleção de vagas do usuário específico.
  /// Caminho no banco: users -> {userId} -> job_applications
  CollectionReference _getCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('job_applications');
  }

  /// ADICIONAR: Salva uma nova vaga no banco de dados.
  Future<void> addJob({
    required String userId,
    required JobApplication job,
  }) async {
    await _getCollection(userId).add(job.toMap());
  }

  /// ATUALIZAR: Modifica uma vaga existente.
  Future<void> updateJob({
    required String userId,
    required JobApplication job,
  }) async {
    // O ID é obrigatório para saber qual documento atualizar
    if (job.id == null) return;

    await _getCollection(userId).doc(job.id).update(job.toMap());
  }

  /// DELETAR: Remove uma vaga do banco de dados.
  Future<void> deleteJob({
    required String userId,
    required String jobId,
  }) async {
    await _getCollection(userId).doc(jobId).delete();
  }

  /// LER (Stream): Busca a lista de vagas em tempo real.
  /// Se o status for informado (ex: 'to_apply'), filtra a lista.
  /// Se status for null, traz tudo.
  Stream<List<JobApplication>> getJobsStream({
    required String userId,
    String? status,
  }) {
    Query query = _getCollection(userId).orderBy('createdAt', descending: true);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    // Transforma os dados brutos do Firebase (Snapshots) em nossa lista de objetos JobApplication
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobApplication.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }
}
