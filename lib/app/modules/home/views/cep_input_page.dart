import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:quipede/app/di/dependencies.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../../enderecos/bloc/endereco_state.dart';
import 'endereco_confirmacao_page.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';
import '../../../core/theme/input_styles.dart';

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
            'logradouro': state.dados['logradouro'] ?? '',
            'bairro': state.dados['bairro'] ?? '',
            'cidade': state.dados['cidade'] ?? '',
            'uf': state.dados['uf'] ?? '',
            'cep': state.dados['cep'] ?? '',
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
              Navigator.pop(context, true);
            }
          });
        }
        if (state is EnderecoOperacaoSucesso) {
          setState(() => _isLoading = false);
          Navigator.pop(context, true);
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
                const Text(
                  'Digite seu CEP',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Encontre seu endereço rapidamente para ver as lojas próximas.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _cepController,
                  focusNode: _focusNode,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cepMaskFormatter],
                  maxLength: 10,
                  textInputAction: TextInputAction.search,
                  onFieldSubmitted: (_) => _isLoading ? null : _buscarCep(),
                  decoration: InputStyles.decoration(
                    label: 'CEP',
                    hint: 'Ex: 12345-678',
                    prefixIcon: Icons.mail_outline,
                  ).copyWith(counterText: ''),
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
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : const Text('Buscar CEP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
