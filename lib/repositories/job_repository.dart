import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/job_application.dart';

class JobRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  JobRepository({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // --- Funções de Banco de Dados (Firestore) ---

  CollectionReference _getCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('job_applications');
  }

  Future<void> addJob({required String userId, required JobApplication job}) async {
    await _getCollection(userId).add(job.toMap());
  }

  Future<void> updateJob({required String userId, required JobApplication job}) async {
    if (job.id == null) return;
    await _getCollection(userId).doc(job.id).update(job.toMap());
  }

  Future<void> deleteJob({required String userId, required String jobId}) async {
    await _getCollection(userId).doc(jobId).delete();
  }

  Stream<List<JobApplication>> getJobsStream({required String userId, String? status}) {
    Query query = _getCollection(userId).orderBy('createdAt', descending: true);
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return JobApplication.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // --- NOVA FUNÇÃO: Upload de Imagem (Storage) ---
  
  Future<String> uploadImage({required String userId, required File imageFile}) async {
    // 1. Cria um nome único para o arquivo (usando a data atual em milissegundos)
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    
    // 2. Define o caminho onde será salvo: users/{id}/uploads/{nome}.jpg
    final Reference ref = _storage.ref().child('users/$userId/uploads/$fileName.jpg');
    
    // 3. Envia o arquivo
    final UploadTask uploadTask = ref.putFile(imageFile);
    
    // 4. Aguarda o envio terminar e pega o Snapshot (resultado)
    final TaskSnapshot snapshot = await uploadTask;
    
    // 5. Pede ao Storage o link público para download dessa foto
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    
    return downloadUrl; // Retorna o link (ex: https://firebasestorage...)
  }
}