
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/modules/auth/bloc/auth_cubit.dart';
import '../../app/modules/auth/bloc/auth_state.dart';

mixin AuthMixin<T extends StatefulWidget> on State<T> {
  void handleAuthError(BuildContext context, Function onAuthSuccess) {
    // Exemplo de como o Interceptor pode notificar a UI.
    // Neste caso, estamos usando um AuthCubit para gerenciar o estado.
    final authCubit = context.read<AuthCubit>();
    
    // Se o token for atualizado br sucesso, executa a ação original.
    // Caso contrário, o AuthCubit irá redirecionar para o login.
    authCubit.stream.listen((state) {
      if (state is AuthAuthenticated) {
        onAuthSuccess();
      }
    });
  }
}
