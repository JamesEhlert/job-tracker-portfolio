import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // Para usar debugPrint

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // Construtor
  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn();

  // Retorna o usuário atual ou null
  User? get currentUser => _firebaseAuth.currentUser;

  // Ouve mudanças na autenticação (login/logout)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Função de Login
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Tenta iniciar o fluxo de login interativo
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('Login cancelado pelo usuário.');
        return null;
      }

      // 2. Obtém os detalhes de autenticação da solicitação
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Cria uma nova credencial para o Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Faz o login no Firebase com as credenciais
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      debugPrint(
        'Usuário logado com sucesso: ${userCredential.user?.displayName}',
      );
      return userCredential.user;
    } catch (e) {
      debugPrint('Erro no AuthRepository: $e');
      return null;
    }
  }

  // Função de Logout
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Erro ao deslogar: $e');
    }
  }
}