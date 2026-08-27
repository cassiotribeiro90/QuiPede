// lib/app/navigation/app_router_listener.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quipede/app/navigation/navigation_cubit.dart';
import 'package:quipede/app/routes/app_router.dart';

import 'navigation_state.dart';

class AppRouterListener extends StatelessWidget {
  final Widget child;
  const AppRouterListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // 🔥 Sincroniza o path inicial se ainda não estiver definido no Cubit
    // Isso garante que Deep Links sejam respeitados no Web
    final cubit = context.read<NavigationCubit>();
    if (cubit.state.path == null) {
      final config = appRouter.routerDelegate.currentConfiguration;
      final initialPath = config.uri.toString();
      cubit.setInitialPath(initialPath);
    }

    return BlocListener<NavigationCubit, NavigationState>(
      listener: (context, state) {
        // 🔥 Função auxiliar para obter a URL atual
        String getCurrentLocation() {
          try {
            final config = appRouter.routerDelegate.currentConfiguration;
            return config.fullPath;
          } catch (e) {
            return 'unknown';
          }
        }

        debugPrint('🔴 [AppRouterListener] ========================================');
        debugPrint('🔴 [AppRouterListener] 📥 NOVO ESTADO RECEBIDO!');
        debugPrint('🔴 [AppRouterListener]    - path: ${state.path}');
        debugPrint('🔴 [AppRouterListener]    - pop: ${state.pop}');
        debugPrint('🔴 [AppRouterListener]    - replace: ${state.replace}');
        debugPrint('🔴 [AppRouterListener]    - queryParams: ${state.queryParams}');
        debugPrint('🔴 [AppRouterListener]    - extra: ${state.extra}');
        debugPrint('🔴 [AppRouterListener] URL atual (antes): ${getCurrentLocation()}');
        debugPrint('🔴 [AppRouterListener] Pode dar pop? ${appRouter.canPop()}');

        // 🔥 NUNCA execute pop se a pilha estiver vazia
        if (state.pop) {
          debugPrint('🔴 [AppRouterListener] 🔥 Pop solicitado!');
          if (appRouter.canPop()) {
            debugPrint('🔴 [AppRouterListener] ⬅️ Executando POP');
            appRouter.pop();
            debugPrint('🔴 [AppRouterListener] URL após pop: ${getCurrentLocation()}');
          } else {
            debugPrint('⚠️ [AppRouterListener] Pop ignorado: pilha vazia');
          }
          debugPrint('🔴 [AppRouterListener] ========================================');
          return;
        }

        if (state.path != null) {
          final path = state.path!;
          final query = state.queryParams;
          final extra = state.extra;
          final fullPath = query != null && query.isNotEmpty
              ? '$path?${Uri(queryParameters: query).query}'
              : path;

          debugPrint('🔴 [AppRouterListener] Path completo: $fullPath');

          if (state.replace) {
            debugPrint('🔴 [AppRouterListener] 🚀 Executando GO para: $fullPath');
            appRouter.go(fullPath, extra: extra);
          } else {
            debugPrint('🔴 [AppRouterListener] 🚀 Executando PUSH para: $fullPath');
            appRouter.push(fullPath, extra: extra);
          }
          
          debugPrint('🔴 [AppRouterListener] URL atual: ${appRouter.routerDelegate.currentConfiguration.uri}');

          debugPrint('🔴 [AppRouterListener] ✅ Navegação concluída com sucesso');
        } else {
          debugPrint('🔴 [AppRouterListener] ⏳ Estado idle (sem path) - ignorando');
        }

        debugPrint('🔴 [AppRouterListener] ========================================');
      },
      child: child,
    );
  }
}