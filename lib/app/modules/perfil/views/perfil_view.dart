import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();

    debugPrint('🧭 [PerfilView] initState');
    
    // Tenta carregar dados iniciais se já estiverem no Cubit
    final user = context.read<AuthCubit>().usuario;
    if (user != null && user.nome.isNotEmpty) {
      _nomeController.text = user.nome;
      _emailController.text = user.email ?? '';
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _salvar() {
    context.read<AuthCubit>().atualizarPerfil(
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthPerfilCompleto) {
          final user = context.read<AuthCubit>().usuario;
          if (user != null) {
            // Se houve uma mudança externa ou confirmação de salvamento, atualiza
            if (_nomeController.text != user.nome) {
              _nomeController.text = user.nome;
            }
            if (_emailController.text != (user.email ?? '')) {
              _emailController.text = user.email ?? '';
            }
            _isInitialized = true;
          }
          
          // Mostra snackbar apenas se não for o carregamento inicial silencioso
          if (state is AuthAuthenticated && !_isInitialized) {
             // Silencioso
          } else {
             // Opcional: mostrar sucesso
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final user = context.read<AuthCubit>().usuario;
        
        // Preenchimento reativo inicial (caso o Cubit carregue depois do initState)
        if (!_isInitialized && user != null && user.nome.isNotEmpty) {
           _nomeController.text = user.nome;
           _emailController.text = user.email ?? '';
           _isInitialized = true;
        }

        return ResponsivePageScaffold(
          appBar: AppBar(
            title: const Text(
              'Meu Perfil',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Meus dados',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Você pode alterar seus dados pessoais.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),
                // 🔹 Nome
                TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // 🔹 Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                // 🔹 Botão salvar
                ElevatedButton(
                  onPressed: state is AuthLoading ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state is AuthLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text('Salvar alterações'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
