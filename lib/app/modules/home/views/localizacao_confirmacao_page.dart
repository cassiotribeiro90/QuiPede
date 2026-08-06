import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quipede/app/di/dependencies.dart';
import 'package:quipede/app/services/navigation_service.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../../enderecos/bloc/endereco_state.dart';
import '../bloc/localizacao_cubit.dart';
import '../../enderecos/models/endereco_model.dart';
import 'widgets/endereco_card.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../core/utils/estados_brasil.dart';
import '../../../core/widgets/app_text_field.dart';

class LocalizacaoConfirmacaoPage extends StatefulWidget {
  final Map<String, dynamic> endereco;
  final double latitude;
  final double longitude;

  const LocalizacaoConfirmacaoPage({
    super.key,
    required this.endereco,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<LocalizacaoConfirmacaoPage> createState() => _LocalizacaoConfirmacaoPageState();
}

class _LocalizacaoConfirmacaoPageState extends State<LocalizacaoConfirmacaoPage> {
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _numeroController.dispose();
    _complementoController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  void _confirmar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ufSigla = converterEstadoParaSigla(widget.endereco['uf'] ?? '');

    final enderecoModel = EnderecoModel(
      logradouro: widget.endereco['logradouro'] ?? '',
      numero: _numeroController.text.trim(),
      bairro: widget.endereco['bairro'] ?? '',
      cidade: widget.endereco['cidade'] ?? '',
      uf: ufSigla,
      cep: widget.endereco['cep'] ?? '',
      complemento: _complementoController.text.trim().isEmpty ? null : _complementoController.text.trim(),
      latitude: widget.latitude,
      longitude: widget.longitude,
    );

    setState(() => _isLoading = true);


    try {
      await getIt<EnderecoCubit>().criarEndereco(enderecoModel);
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
        if (state is EnderecoCriado) {
          setState(() => _isLoading = false);

          // ✅ Sincroniza o endereço completo (incluindo ID) com o LocalizacaoCubit
          context.read<LocalizacaoCubit>().definirEnderecoCompleto(state.endereco, origem: 'manual');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Endereço adicionado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          // ✅ Endereço criado → vai direto para Home, limpando a pilha
          getIt<NavigationService>().goToHomeAndRemoveAll();
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
        if (state is EnderecoLoading) {
          setState(() => _isLoading = true);
        }
      },
      child: ResponsivePageScaffold(
        appBar: AppBar(
          title: const Text('Confirmar Localização'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => getIt<NavigationService>().pop(),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Icon(Icons.location_on, size: 64, color: Colors.orange),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Encontramos este endereço:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                EnderecoCard(
                  logradouro: widget.endereco['logradouro'] ?? '',
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
                  onPressed: () => getIt<NavigationService>().pop(),
                  child: const Text('Tentar outra forma'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}