import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quipede/app/navigation/navigation_cubit.dart';
import 'package:quipede/app/core/widgets/primary_button.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../../enderecos/bloc/endereco_state.dart';
import '../../enderecos/models/endereco_model.dart';
import 'widgets/endereco_card.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../core/utils/estados_brasil.dart';
import '../../../core/widgets/app_text_field.dart';

class EnderecoConfirmacaoPage extends StatelessWidget {
  final Map<String, dynamic> endereco;
  final double latitude;
  final double longitude;

  const EnderecoConfirmacaoPage({
    super.key,
    required this.endereco,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return _EnderecoConfirmacaoBody(
      endereco: endereco,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class _EnderecoConfirmacaoBody extends StatefulWidget {
  final Map<String, dynamic> endereco;
  final double latitude;
  final double longitude;

  const _EnderecoConfirmacaoBody({
    required this.endereco,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<_EnderecoConfirmacaoBody> createState() => _EnderecoConfirmacaoBodyState();
}

class _EnderecoConfirmacaoBodyState extends State<_EnderecoConfirmacaoBody> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _referenciaController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _numeroController.dispose();
    _complementoController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final ufSigla = converterEstadoParaSigla(widget.endereco['uf'] ?? '');

    final enderecoModel = EnderecoModel(
      logradouro: widget.endereco['logradouro'] ?? widget.endereco['descricao'] ?? '',
      numero: _numeroController.text.trim(),
      bairro: widget.endereco['bairro'] ?? '',
      cidade: widget.endereco['cidade'] ?? '',
      uf: ufSigla,
      cep: widget.endereco['cep'] ?? '',
      complemento: _complementoController.text.trim().isEmpty ? null : _complementoController.text.trim(),
      referencia: _referenciaController.text.trim().isEmpty ? null : _referenciaController.text.trim(),
      latitude: widget.latitude,
      longitude: widget.longitude,
    );

    setState(() => _isLoading = true);

    context.read<EnderecoCubit>().criarEndereco(enderecoModel);
  }

  @override
  Widget build(BuildContext context) {
    final navigationCubit = context.read<NavigationCubit>();

    return BlocListener<EnderecoCubit, EnderecoState>(
      listenWhen: (previous, current) {
        return current is EnderecoCriado || current is EnderecoError || current is EnderecoLoading;
      },
      listener: (context, state) {
        if (state is EnderecoCriado) {
          debugPrint('✅ [EnderecoConfirmacaoPage] Endereço criado: ID ${state.endereco.id}');
          setState(() => _isLoading = false);

          // ✅ NAVEGA DIRETO PARA HOME via NavigationCubit
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              navigationCubit.goToHomeAndRemoveAll();
            }
          });
        } else if (state is EnderecoError) {
          debugPrint('❌ [EnderecoConfirmacaoPage] Erro: ${state.message}');
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is EnderecoLoading) {
          setState(() => _isLoading = true);
        }
      },
      child: ResponsivePageScaffold(
        appBar: AppBar(
          title: const Text('Confirmar Endereço'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/onboarding');
              }
            },
          ),
        ),
        backgroundColor: Colors.white,
        body: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  EnderecoCard(
                    logradouro: widget.endereco['logradouro'] ?? widget.endereco['descricao'] ?? '',
                    bairro: widget.endereco['bairro'] ?? '',
                    cidade: widget.endereco['cidade'] ?? '',
                    uf: converterEstadoParaSigla(widget.endereco['uf'] ?? ''),
                    cep: widget.endereco['cep'] ?? '',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: AppTextField(
                          controller: _numeroController,
                          label: 'Número',
                          isRequired: true,
                          hint: '123',
                          keyboardType: TextInputType.number,
                          validator: (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          controller: _complementoController,
                          label: 'Complemento',
                          hint: 'Apto, Bloco, etc.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _referenciaController,
                    label: 'Ponto de referência',
                    hint: 'Ex: portão verde, próximo ao mercado',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    onPressed: _confirmar,
                    label: 'Confirmar Endereço',
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}