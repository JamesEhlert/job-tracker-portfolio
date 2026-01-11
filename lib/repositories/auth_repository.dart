import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Repositório responsável por gerenciar a autenticação do usuário.
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  // Construtor: Permite injeção de dependência (útil para testes)
  AuthRepository({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Retorna o usuário atual se estiver logado, ou null se não estiver.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Fluxo de dados (Stream) que avisa quando o usuário loga ou desloga.
  /// A interface vai "escutar" isso para mudar de tela automaticamente.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Realiza o login usando a conta do Google.
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Abre a janela nativa do Google no Android
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // Usuário cancelou o login
      }

      // 2. Obtém os tokens de segurança da conta escolhida
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Cria uma credencial para o Firebase usando esses tokens
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Faz o login final no Firebase Auth
      final UserCredential userCredential = 
          await _firebaseAuth.signInWithCredential(credential);
      
      return userCredential.user;
    } catch (e) {
      // Em um app real, reportaríamos esse erro para um sistema de logs
      print('Erro no login com Google: $e');
      rethrow; // Repassa o erro para a tela tratar (ex: mostrar aviso)
    }
  }

  /// Desloga o usuário do aplicativo.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}