// server.dart - Salve na pasta build/web
import 'dart:io';

void main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  stdout.writeln('Servidor SPA rodando em http://localhost:8080');
  stdout.writeln('Pressione Ctrl+C para parar');

  await for (var request in server) {
    try {
      final path = request.uri.path;
      final filePath = path == '/' ? '/index.html' : path;
      final file = File('.$filePath');

      if (await file.exists()) {
        // Arquivo existe → serve
        final content = await file.readAsBytes();
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = _getContentType(filePath)
          ..add(content);
      } else {
        // ✅ SPA: redireciona para index.html
        final indexFile = File('./index.html');
        if (await indexFile.exists()) {
          final content = await indexFile.readAsBytes();
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.html
            ..add(content);
        } else {
          request.response
            ..statusCode = HttpStatus.notFound
            ..write('404 - Página não encontrada');
        }
      }
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write('500 - Erro interno: $e');
    } finally {
      await request.response.close();
    }
  }
}

ContentType _getContentType(String path) {
  if (path.endsWith('.html') || path.endsWith('.htm')) {
    return ContentType.html;
  }
  if (path.endsWith('.js')) {
    return ContentType('application', 'javascript');
  }
  if (path.endsWith('.css')) {
    return ContentType('text', 'css');
  }
  if (path.endsWith('.json')) {
    return ContentType.json;
  }
  if (path.endsWith('.png')) {
    return ContentType('image', 'png');
  }
  if (path.endsWith('.jpg') || path.endsWith('.jpeg')) {
    return ContentType('image', 'jpeg');
  }
  if (path.endsWith('.svg')) {
    return ContentType('image', 'svg+xml');
  }
  if (path.endsWith('.ico')) {
    return ContentType('image', 'x-icon');
  }
  if (path.endsWith('.webp')) {
    return ContentType('image', 'webp');
  }
  if (path.endsWith('.wasm')) {
    return ContentType('application', 'wasm');
  }
  if (path.endsWith('.txt')) {
    return ContentType.text;
  }
  return ContentType.binary;
}