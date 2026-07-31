import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/endereco_cubit.dart';
import '../bloc/endereco_state.dart';
import '../models/endereco_model.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../../shared/widgets/web_back_button_handler.dart';

class EnderecoFormView extends StatefulWidget {
  final EnderecoModel? endereco;
  final bool isEditing;

  const EnderecoFormView({
    super.key,
    this.endereco,
    this.isEditing = false,
  });

  @override
  State<EnderecoFormView> createState() => _EnderecoFormViewState();
}

class _EnderecoFormViewState extends State<EnderecoFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _cepController;
  late final TextEditingController _logradouroController;
  late final TextEditingController _numeroController;
  late final TextEditingController _complementoController;
  late final TextEditingController _bairroController;
  late final TextEditingController _cidadeController;
  late final TextEditingController _ufController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.endereco;
    _labelController = TextEditingController(text: e?.label ?? '');
    _cepController = TextEditingController(text: e?.cep ?? '');
    _logradouroController = TextEditingController(text: e?.logradouro ?? '');
    _numeroController = TextEditingController(text: e?.numero ?? '');
    _complementoController = TextEditingController(text: e?.complemento ?? '');
    _bairroController = TextEditingController(text: e?.bairro ?? '');
    _cidadeController = TextEditingController(text: e?.cidade ?? '');
    _ufController = TextEditingController(text: e?.uf ?? '');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebBackButtonHandler(
      child: BlocConsumer<EnderecoCubit, EnderecoState>(
        listenWhen: (previous, current) {
          return current is EnderecoOperacaoSucesso ||
              current is EnderecoError ||
              current is EnderecoCepCarregado ||
              current is EnderecoCepBuscando;
        },
        listener: (context, state) {
          if (state is EnderecoOperacaoSucesso) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensagem),
                backgroundColor: Colors.green,
              ),
            );
            if (mounted) {
              Navigator.pop(context, true);
            }
          }
          if (state is EnderecoError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is EnderecoCepCarregado) {
            setState(() => _isLoading = false);
            _logradouroController.text = state.dados['logradouro'] ?? '';
            _bairroController.text = state.dados['bairro'] ?? '';
            _cidadeController.text = state.dados['cidade'] ?? '';
            _ufController.text = state.dados['uf'] ?? '';
          }
          if (state is EnderecoCepBuscando) {
            setState(() => _isLoading = true);
          }
        },
        builder: (context, state) {
          final isLoading = state is EnderecoLoading || _isLoading;

          return ResponsivePageScaffold(
            appBar: AppBar(
              title: Text(widget.isEditing ? 'Editar Endereço' : 'Novo Endereço'),
              backgroundColor: context.surfaceColor,
              foregroundColor: context.textPrimary,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : _salvar,
                  child: Text(
                    'Salvar',
                    style: TextStyle(
                      color: context.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: context.backgroundColor,
            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _labelController,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Apelido (opcional)',
                            hintText: 'Ex: Casa, Trabalho, etc.',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cepController,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            labelText: 'CEP *',
                            hintText: '12345-678',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
                                      if (cep.length == 8) {
                                        context.read<EnderecoCubit>().buscarCep(cep);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Digite um CEP válido (8 dígitos)')),
                                        );
                                      }
                                    },
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Digite o CEP';
                            final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                            if (cleaned.length != 8) return 'CEP inválido (8 dígitos)';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _logradouroController,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Logradouro *',
                            hintText: 'Rua, Avenida, etc.',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Digite o logradouro';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _numeroController,
                                enabled: !isLoading,
                                decoration: const InputDecoration(
                                  labelText: 'Número *',
                                  hintText: '123',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Digite o número';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _complementoController,
                                enabled: !isLoading,
                                decoration: const InputDecoration(
                                  labelText: 'Complemento',
                                  hintText: 'Apto, Bloco, etc.',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bairroController,
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Bairro *',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Digite o bairro';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _cidadeController,
                                enabled: !isLoading,
                                decoration: const InputDecoration(
                                  labelText: 'Cidade *',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Digite a cidade';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _ufController,
                                enabled: !isLoading,
                                decoration: const InputDecoration(
                                  labelText: 'UF *',
                                ),
                                maxLength: 2,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Digite a UF';
                                  if (value.length != 2) return 'UF inválida';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _salvar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(widget.isEditing ? 'Atualizar' : 'Cadastrar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final endereco = EnderecoModel(
      id: widget.endereco?.id,
      cep: _cepController.text,
      logradouro: _logradouroController.text,
      numero: _numeroController.text,
      complemento: _complementoController.text.isNotEmpty ? _complementoController.text : null,
      bairro: _bairroController.text,
      cidade: _cidadeController.text,
      uf: _ufController.text,
      label: _labelController.text.isNotEmpty ? _labelController.text : null,
      principal: widget.endereco?.principal ?? false,
    );

    try {
      final cubit = context.read<EnderecoCubit>();
      if (widget.isEditing) {
        await cubit.atualizarEndereco(endereco);
      } else {
        await cubit.criarEndereco(endereco);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
