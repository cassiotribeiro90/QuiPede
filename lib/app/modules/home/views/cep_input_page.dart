import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:quipede/app/di/dependencies.dart';
import 'package:quipede/app/core/theme/app_text_styles.dart';
import 'package:quipede/app/routes/app_routes.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../../enderecos/bloc/endereco_state.dart';
import 'endereco_confirmacao_page.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';

class CepInputPage extends StatelessWidget {
  const CepInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<EnderecoCubit>(),
      child: const _CepInputBody(),
    );
  }
}

class _CepInputBody extends StatefulWidget {
  const _CepInputBody();

  @override
  State<_CepInputBody> createState() => _CepInputBodyState();
}

class _CepInputBodyState extends State<_CepInputBody> {
  final _cepController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;

  final _cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _cepController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _buscarCep() {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um CEP válido (8 dígitos)')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    context.read<EnderecoCubit>().buscarCep(cep);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnderecoCubit, EnderecoState>(
      listener: (context, state) {
        if (state is EnderecoCepCarregado) {
          setState(() => _isLoading = false);
          final endereco = {
            'logradouro': state.dadosCep['logradouro'] ?? '',
            'bairro': state.dadosCep['bairro'] ?? '',
            'cidade': state.dadosCep['cidade'] ?? '',
            'uf': state.dadosCep['uf'] ?? '',
            'cep': state.dadosCep['cep'] ?? '',
          };
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EnderecoConfirmacaoPage(
                endereco: endereco,
                latitude: 0.0,
                longitude: 0.0,
              ),
            ),
          ).then((result) {
            if (result == true && mounted) {
              // ✅ Endereço confirmado → vai direto para Home, limpando a pilha
              Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
            }
          });
        }
        if (state is EnderecoCriado) {
          setState(() => _isLoading = false);
          if (mounted) {
            // ✅ Endereço criado → vai direto para Home, limpando a pilha
            Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
          }
        }
        if (state is EnderecoError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
        if (state is EnderecoCepBuscando) {
          setState(() => _isLoading = true);
        }
      },
      child: ResponsivePageScaffold(
        appBar: AppBar(
          title: const Text('Informar CEP'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Colors.white,
        body: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Digite seu CEP',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Encontre seu endereço rapidamente para ver as lojas próximas.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _cepController,
                  label: 'CEP',
                  hint: '000000-000',
                  prefixIcon: Icons.mail_outline,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cepMaskFormatter],
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) => _isLoading ? null : _buscarCep(),
                  autofocus: true,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _buscarCep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Text(
                      'Buscar CEP',
                      style: AppTextStyles.button.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}