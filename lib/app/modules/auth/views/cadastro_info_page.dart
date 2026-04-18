import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../routes/app_routes.dart';
import '../../../../app/core/utils/masks.dart';
import '../../../../app/core/utils/validators.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../models/cadastro_models.dart';

class CadastroInfoPage extends StatefulWidget {
  const CadastroInfoPage({super.key});

  @override
  State<CadastroInfoPage> createState() => _CadastroInfoPageState();
}

class _CadastroInfoPageState extends State<CadastroInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _proximaEtapa() async {
    if (_formKey.currentState!.validate()) {
      final telefoneLimpo = _telefoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

      final info = CadastroInfoModel(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        telefone: telefoneLimpo,
        senha: _senhaController.text.trim(),
        confirmarSenha: _confirmarSenhaController.text.trim(),
      );
      
      final isValid = await context.read<AuthCubit>().validarEtapa1(info.toJson());
      
      if (isValid && mounted) {
        Navigator.pushNamed(
          context, 
          Routes.cadastroEndereco, 
          arguments: info
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro - Etapa 1 de 2'),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LinearProgressIndicator(value: 0.5),
                const SizedBox(height: 32),
                Text(
                  'Informações Pessoais',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Preencha seus dados para criar sua conta.'),
                const SizedBox(height: 32),
                
                TextFormField(
                  controller: _nomeController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Informe seu nome' : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: AppValidators.validateEmail,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _telefoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    PhoneInputFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    hintText: '(00) 00000-0000',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: AppValidators.validatePhone,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _senhaController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe uma senha';
                    if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _confirmarSenhaController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Confirme sua senha';
                    if (value != _senhaController.text) return 'As senhas não coincidem';
                    return null;
                  },
                  onFieldSubmitted: (_) => _proximaEtapa(),
                ),
                const SizedBox(height: 32),
                
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _proximaEtapa,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('CONTINUAR', style: TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
