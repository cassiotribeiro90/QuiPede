import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/endereco_model.dart';
import '../bloc/endereco_cubit.dart';
import '../bloc/endereco_state.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';

class EnderecoEditView extends StatefulWidget {
  final EnderecoModel endereco;
  const EnderecoEditView({required this.endereco, super.key});

  @override
  State<EnderecoEditView> createState() => _EnderecoEditViewState();
}

class _EnderecoEditViewState extends State<EnderecoEditView> {
  late TextEditingController _numeroController;
  late TextEditingController _complementoController;
  late TextEditingController _referenciaController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _numeroController = TextEditingController(text: widget.endereco.numero);
    _complementoController = TextEditingController(text: widget.endereco.complemento);
    _referenciaController = TextEditingController(text: widget.endereco.referencia);
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _complementoController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnderecoCubit, EnderecoState>(
      listenWhen: (previous, current) {
        // ✅ Só escuta o estado específico de atualização ou erro durante o saving
        return _isSaving && (current is EnderecoAtualizado || current is EnderecoError);
      },
      listener: (context, state) {
        if (state is EnderecoAtualizado) {
          print('✅ [EnderecoEditView] Endereço atualizado, voltando para lista');
          if (mounted) {
            Navigator.pop(context);
          }
        } else if (state is EnderecoError) {
          print('❌ [EnderecoEditView] Erro ao atualizar: ${state.message}');
          setState(() => _isSaving = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: ResponsivePageScaffold(
        appBar: AppBar(
          title: const Text('Editar Endereço'),
          backgroundColor: context.surfaceColor,
          foregroundColor: context.textPrimary,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReadOnlyField('CEP', widget.endereco.cep),
                _buildReadOnlyField('Logradouro', widget.endereco.logradouro),
                _buildReadOnlyField('Bairro', widget.endereco.bairro),
                _buildReadOnlyField('Cidade/UF', '${widget.endereco.cidade} - ${widget.endereco.uf}'),

                const SizedBox(height: 20),
                const Divider(height: 40),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _numeroController,
                  decoration: const InputDecoration(labelText: 'Número', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _complementoController,
                  decoration: const InputDecoration(labelText: 'Complemento', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _referenciaController,
                  decoration: const InputDecoration(labelText: 'Ponto de referência', border: OutlineInputBorder()),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _salvar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text('Salvar Alterações', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  void _salvar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final enderecoAtualizado = widget.endereco.copyWith(
      numero: _numeroController.text,
      complemento: _complementoController.text,
      referencia: _referenciaController.text,
    );

    print('📝 [EnderecoEditView] Salvando alterações do endereço ID ${enderecoAtualizado.id}');
    context.read<EnderecoCubit>().atualizarEndereco(enderecoAtualizado);
  }
}