import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/masks.dart';
import '../../../../core/utils/validators.dart';
import '../../../home/bloc/localizacao_cubit.dart';
import '../../../home/bloc/localizacao_state.dart';
import '../../bloc/auth_cubit.dart';
import '../../bloc/auth_state.dart';
import 'custom_text_field.dart';

class CadastroFormWidget extends StatefulWidget {
  final bool isCompletarCadastro;
  final VoidCallback? onSuccess;

  const CadastroFormWidget({
    super.key,
    this.isCompletarCadastro = false,
    this.onSuccess,
  });

  @override
  State<CadastroFormWidget> createState() => _CadastroFormWidgetState();
}

class _CadastroFormWidgetState extends State<CadastroFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termosAceitos = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (!_termosAceitos) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você precisa aceitar os termos de uso para continuar.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      FocusScope.of(context).unfocus();

      final authCubit = context.read<AuthCubit>();
      final authState = authCubit.state;
      
      if (authState is AuthGuest || widget.isCompletarCadastro) {
        await authCubit.completarCadastroConvidado(
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          senha: _senhaController.text.trim(),
          telefone: _telefoneController.text.replaceAll(RegExp(r'\D'), ''),
        );
      } else {
        final dados = {
          'nome': _nomeController.text.trim(),
          'email': _emailController.text.trim(),
          'telefone': _telefoneController.text.replaceAll(RegExp(r'\D'), ''),
          'senha': _senhaController.text.trim(),
          'confirmar_senha': _confirmarSenhaController.text.trim(),
          'termos_aceitos': 1,
        };

        final locState = context.read<LocalizacaoCubit>().state;
        if (locState is LocalizacaoCarregada) {
          dados['endereco'] = locState.endereco.toJson();
        }
        await authCubit.cadastrar(dados);
      }
      
      if (authCubit.state is AuthAuthenticated && widget.onSuccess != null) {
        widget.onSuccess!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF57C00);

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nomeController,
                hintText: 'Nome completo',
                prefixIcon: Icons.person_outline,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.isEmpty) ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                hintText: 'E-mail',
                prefixIcon: Icons.email_outlined,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: AppValidators.validateEmail,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _telefoneController,
                hintText: 'Telefone',
                prefixIcon: Icons.phone_outlined,
                enabled: !isLoading,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  PhoneInputFormatter(),
                ],
                validator: AppValidators.validatePhone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _senhaController,
                hintText: 'Senha',
                prefixIcon: Icons.lock_outline,
                enabled: !isLoading,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe uma senha';
                  if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmarSenhaController,
                hintText: 'Confirmar senha',
                prefixIcon: Icons.lock_outline,
                enabled: !isLoading,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => isLoading ? null : _submit(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Confirme sua senha';
                  if (value != _senhaController.text) return 'As senhas não coincidem';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTermos(primaryColor),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        widget.isCompletarCadastro ? 'FINALIZAR E COMPRAR' : 'CADASTRAR',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTermos(Color primaryColor) {
    return FormField<bool>(
      initialValue: _termosAceitos,
      validator: (value) {
        if (value == null || value == false) {
          return 'Você deve aceitar os termos';
        }
        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _termosAceitos,
                  activeColor: primaryColor,
                  onChanged: (val) {
                    setState(() => _termosAceitos = val ?? false);
                    state.didChange(val);
                  },
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                      children: [
                        const TextSpan(text: 'Eu li e aceito os '),
                        TextSpan(
                          text: 'Termos de Uso',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        const TextSpan(text: ' e a '),
                        TextSpan(
                          text: 'Política de Privacidade',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
