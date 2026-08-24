import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import '../../app/routes/app_routes.dart';

/// Widget que captura o evento de voltar do navegador e redireciona para a navegação do app
class WebBackButtonHandler extends StatelessWidget {
  final Widget child;
  final VoidCallback? onBack;

  const WebBackButtonHandler({
    super.key,
    required this.child,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    // 🔥 SÓ APLICA NO WEB
    if (!kIsWeb) {
      return child;
    }

    return PopScope(
      canPop: false, // 🔥 IMPEDE O POP DIRETO
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        
        // 🔥 CHAMA O CALLBACK PERSONALIZADO OU FAZ O POP PADRÃO
        if (onBack != null) {
          onBack!();
        } else {
          _handleBack(context);
        }
      },
      child: child,
    );
  }

  void _handleBack(BuildContext context) {
    // 🔥 VERIFICA SE PODE VOLTAR
    if (context.canPop()) {
      context.pop();
    } else {
      // 🔥 SE NÃO TIVER MAIS PÁGINAS NO HISTÓRICO, VOLTA PARA A HOME
      context.go(Routes.home);
    }
  }
}
