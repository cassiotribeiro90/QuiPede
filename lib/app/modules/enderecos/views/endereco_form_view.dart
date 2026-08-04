import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/endereco_cubit.dart';
import '../bloc/endereco_state.dart';
import '../models/endereco_model.dart';
import '../../../core/utils/estados_brasil.dart';
import '../../../core/theme/input_styles.dart';

class EnderecoFormView extends StatefulWidget {
  final EnderecoModel? endereco;
  final bool isEditing;
  final String? modo;

  const EnderecoFormView({
    super.key,
    this.endereco,
    this.isEditing = false,
    this.modo,
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
  late final FocusNode _cepFocusNode;
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
    _cepFocusNode = FocusNode();

    if (widget.modo == 'cep' && !widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cepFocusNode.requestFocus();
      });
    }
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
    _cepFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnderecoCubit, EnderecoState>(
      listener: (context, state) {
        if (state is EnderecoCepCarregado) {
          setState(() => _isLoading = false);
          _logradouroController.text = state.dados['logradouro'] ?? '';
          _bairroController.text = state.dados['bairro'] ?? '';
          _cidadeController.text = state.dados['cidade'] ?? '';
          _ufController.text = converterEstadoParaSigla(state.dados['uf'] ?? '');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CEP encontrado! Preencha o número.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state is EnderecoCepBuscando) {
          setState(() => _isLoading = true);
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
        if (state is EnderecoOperacaoSucesso) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensagem),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      },
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _labelController,
                enabled: !_isLoading,
                decoration: InputStyles.decoration(
                  label: 'Apelido (opcional)',
                  hint: 'Ex: Casa, Trabalho, etc.',
                  prefixIcon: Icons.bookmark_outline,
                ),
              ),
              const SizedBox(height: 16),

              // CEP com busca
              TextFormField(
                controller: _cepController,
                focusNode: _cepFocusNode,
                enabled: !_isLoading,
                decoration: InputStyles.decoration(
                  label: 'CEP *',
                  hint: '12345-678',
                  prefixIcon: Icons.location_on_outlined,
                  suffixIcon: IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    onPressed: _isLoading ? null : _buscarCep,
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
                enabled: !_isLoading,
                decoration: InputStyles.decoration(
                  label: 'Logradouro *',
                  hint: 'Rua, Avenida, etc.',
                  prefixIcon: Icons.home_outlined,
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
                      enabled: !_isLoading,
                      decoration: InputStyles.decoration(
                        label: 'Número *',
                        hint: '123',
                        prefixIcon: Icons.numbers,
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
                      enabled: !_isLoading,
                      decoration: InputStyles.decoration(
                        label: 'Complemento',
                        hint: 'Apto, Bloco, etc.',
                        prefixIcon: Icons.add_home_outlined,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bairroController,
                enabled: !_isLoading,
                decoration: InputStyles.decoration(
                  label: 'Bairro *',
                  prefixIcon: Icons.map_outlined,
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
                      enabled: !_isLoading,
                      decoration: InputStyles.decoration(
                        label: 'Cidade *',
                        prefixIcon: Icons.location_city_outlined,
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
                      enabled: !_isLoading,
                      decoration: InputStyles.decoration(
                        label: 'UF *',
                      ),
                      maxLength: 2,
                      textCapitalization: TextCapitalization.characters,
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
                  onPressed: _isLoading ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
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
    );
  }

  void _buscarCep() {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length == 8) {
      context.read<EnderecoCubit>().buscarCep(cep);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um CEP válido (8 dígitos)')),
      );
    }
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
      uf: _ufController.text.toUpperCase(),
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
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
