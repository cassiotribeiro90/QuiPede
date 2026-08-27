import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/masks.dart';
import '../../../../core/utils/validators.dart';
import '../../bloc/auth_cubit.dart';
import '../../bloc/auth_state.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

class CadastroFormWidget extends StatefulWidget {
  final bool isCompletarCadastro;
  final VoidCallback? onSuccess;
  final String? telefonePreenchido;

  const CadastroFormWidget({
    super.key,
    this.isCompletarCadastro = false,
    this.onSuccess,
    this.telefonePreenchido,
  });

  @override
  State<CadastroFormWidget> createState() => _CadastroFormWidgetState();
}

class _CadastroFormWidgetState extends State<CadastroFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();

  bool _termosAceitos = true;

  @override
  void initState() {
    super.initState();
    if (widget.telefonePreenchido != null) {
      _telefoneController.text = widget.telefonePreenchido!;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
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
      
      await authCubit.completarCadastroConvidado(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.replaceAll(RegExp(r'\D'), ''),
      );
      
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
              AppTextField(
                controller: _nomeController,
                label: 'Nome completo',
                prefixIcon: Icons.person_outline,
                enabled: !isLoading,
                isRequired: true,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.isEmpty) ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailController,
                label: 'E-mail',
                prefixIcon: Icons.email_outlined,
                enabled: !isLoading,
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: AppValidators.validateEmail,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _telefoneController,
                label: 'Telefone',
                prefixIcon: Icons.phone_outlined,
                enabled: false,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  PhoneInputFormatter(),
                ],
              ),
              const SizedBox(height: 20),
              _buildTermos(primaryColor),
              const SizedBox(height: 32),
              PrimaryButton(
                onPressed: _submit,
                label: widget.isCompletarCadastro ? 'FINALIZAR E COMPRAR' : 'SALVAR DADOS',
                isLoading: isLoading,
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
