// lib/app/modules/enderecos/views/endereco_edit_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/endereco_cubit.dart';
import '../bloc/endereco_state.dart';
import '../models/endereco_model.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../core/utils/estados_brasil.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';

class EnderecoEditView extends StatefulWidget {
  final EnderecoModel? endereco;

  const EnderecoEditView({
    super.key,
    this.endereco,
  });

  @override
  State<EnderecoEditView> createState() => _EnderecoEditViewState();
}

class _EnderecoEditViewState extends State<EnderecoEditView> {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final _referenciaController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _preencherCampos();
  }

  void _preencherCampos() {
    final endereco = widget.endereco;
    if (endereco != null) {
      _cepController.text = endereco.cep;
      _logradouroController.text = endereco.logradouro;
      _numeroController.text = endereco.numero;
      _complementoController.text = endereco.complemento ?? '';
      _bairroController.text = endereco.bairro;
      _cidadeController.text = endereco.cidade;
      _ufController.text = endereco.uf;
      _referenciaController.text = endereco.referencia ?? '';
    }
  }

  @override
  void dispose() {
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
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

    final ufSigla = converterEstadoParaSigla(_ufController.text.trim());

    final enderecoModel = EnderecoModel(
      id: widget.endereco?.id,
      cep: _cepController.text.trim(),
      logradouro: _logradouroController.text.trim(),
      numero: _numeroController.text.trim(),
      bairro: _bairroController.text.trim(),
      cidade: _cidadeController.text.trim(),
      uf: ufSigla,
      complemento: _complementoController.text.trim().isEmpty ? null : _complementoController.text.trim(),
      referencia: _referenciaController.text.trim().isEmpty ? null : _referenciaController.text.trim(),
      latitude: widget.endereco?.latitude,
      longitude: widget.endereco?.longitude,
      principal: widget.endereco?.principal ?? false,
    );

    setState(() => _isLoading = true);

    if (widget.endereco != null && widget.endereco!.id != null) {
      // EDITANDO
      context.read<EnderecoCubit>().atualizarEndereco(enderecoModel);
    } else {
      // CRIANDO NOVO
      context.read<EnderecoCubit>().criarEndereco(enderecoModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.endereco != null && widget.endereco!.id != null;

    return BlocListener<EnderecoCubit, EnderecoState>(
      listenWhen: (previous, current) {
        // ✅ Verifica se o estado atual é um dos que nos interessam
        return current is EnderecoCriado ||
            current is EnderecoAtualizado ||
            current is EnderecoError ||
            current is EnderecoLoading;
      },
      listener: (context, state) {
        // ✅ Verifica se o estado é EnderecoCriado
        if (state is EnderecoCriado) {
          debugPrint('✅ [EnderecoEditView] Endereço criado: ID ${state.endereco.id}');
          setState(() => _isLoading = false);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/meus-enderecos');
              }
            }
          });
          return;
        }

        // ✅ Verifica se o estado é EnderecoAtualizado
        if (state is EnderecoAtualizado) {
          debugPrint('✅ [EnderecoEditView] Endereço atualizado: ID ${state.endereco.id}');
          setState(() => _isLoading = false);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/meus-enderecos');
              }
            }
          });
          return;
        }

        // ✅ Verifica se o estado é EnderecoError
        if (state is EnderecoError) {
          debugPrint('❌ [EnderecoEditView] Erro: ${state.message}');
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // ✅ Verifica se o estado é EnderecoLoading
        if (state is EnderecoLoading) {
          setState(() => _isLoading = true);
          return;
        }
      },
      child: ResponsivePageScaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Editar Endereço' : 'Novo Endereço'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/meus-enderecos');
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
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          controller: _cepController,
                          label: 'CEP',
                          isRequired: true,
                          hint: '00000-000',
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                          (value == null || value.isEmpty) ? 'Obrigatório' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: AppTextField(
                          controller: _logradouroController,
                          label: 'Logradouro',
                          isRequired: true,
                          hint: 'Rua, Avenida, etc.',
                          validator: (value) =>
                          (value == null || value.isEmpty) ? 'Obrigatório' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: AppTextField(
                          controller: _numeroController,
                          label: 'Número',
                          isRequired: true,
                          hint: '123',
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                          (value == null || value.isEmpty) ? 'Obrigatório' : null,
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
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          controller: _bairroController,
                          label: 'Bairro',
                          isRequired: true,
                          hint: 'Bairro',
                          validator: (value) =>
                          (value == null || value.isEmpty) ? 'Obrigatório' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: AppTextField(
                          controller: _cidadeController,
                          label: 'Cidade',
                          isRequired: true,
                          hint: 'Cidade',
                          validator: (value) =>
                          (value == null || value.isEmpty) ? 'Obrigatório' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _ufController,
                    label: 'UF',
                    isRequired: true,
                    hint: 'SP, RJ, MG, etc.',
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Obrigatório';
                      final sigla = converterEstadoParaSigla(value.trim());
                      if (sigla.isEmpty) return 'UF inválido';
                      return null;
                    },
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
                    onPressed: _salvar,
                    label: isEditing ? 'Atualizar Endereço' : 'Criar Endereço',
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