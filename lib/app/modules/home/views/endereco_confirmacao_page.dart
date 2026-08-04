import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quipede/app/di/dependencies.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../../enderecos/bloc/endereco_state.dart';
import '../../enderecos/models/endereco_model.dart';
import 'widgets/endereco_card.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../core/utils/estados_brasil.dart';
import '../../../core/theme/input_styles.dart';

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
    return BlocProvider.value(
      value: getIt<EnderecoCubit>(),
      child: _EnderecoConfirmacaoBody(
        endereco: endereco,
        latitude: latitude,
        longitude: longitude,
      ),
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

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<EnderecoCubit>().criarEndereco(enderecoModel);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnderecoCubit, EnderecoState>(
      listener: (context, state) {
        if (state is EnderecoOperacaoSucesso) {
          setState(() => _isLoading = false);
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.mensagem), backgroundColor: Colors.green),
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pop(context, true);
            }
          });
        } else if (state is EnderecoError) {
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                ),
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
                      child: TextFormField(
                        controller: _numeroController,
                        keyboardType: TextInputType.number,
                        decoration: InputStyles.decoration(
                          label: 'Número *',
                          hint: '123',
                          prefixIcon: Icons.numbers,
                        ).copyWith(errorStyle: const TextStyle(height: 0)),
                        validator: (value) => (value == null || value.isEmpty) ? '' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _complementoController,
                        decoration: InputStyles.decoration(
                          label: 'Complemento (opcional)',
                          hint: 'Apto, Bloco, etc.',
                          prefixIcon: Icons.add_home_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _referenciaController,
                  maxLines: 2,
                  decoration: InputStyles.decoration(
                    label: 'Ponto de referência (opcional)',
                    hint: 'Ex: portão verde, próximo ao mercado',
                    prefixIcon: Icons.info_outline,
                  ).copyWith(alignLabelWithHint: true),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirmar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Confirmar Endereço',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
