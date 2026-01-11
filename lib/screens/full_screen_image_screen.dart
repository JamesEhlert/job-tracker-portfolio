import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Tela dedicada para visualizar uma imagem em tela cheia.
/// Permite zoom (pinça) e movimentação (pan).
class FullScreenImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para destacar a imagem (estilo galeria)
      
      // AppBar transparente para permitir voltar, mas sem atrapalhar a visão
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      // InteractiveViewer é o widget mágico que permite Zoom e Pan (arrastar)
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // Permite arrastar a imagem se estiver com zoom
          boundaryMargin: const EdgeInsets.all(20), // Margem de segurança
          minScale: 0.5, // Zoom mínimo (afastar)
          maxScale: 4.0, // Zoom máximo (4x de aproximação)
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain, // Garante que a imagem inteira caiba na tela inicialmente
            
            // Loading (enquanto carrega a imagem em alta resolução)
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            
            // Tratamento de erro (se a imagem não existir mais)
            errorWidget: (context, url, error) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.white, size: 50),
                SizedBox(height: 8),
                Text('Erro ao carregar imagem', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}