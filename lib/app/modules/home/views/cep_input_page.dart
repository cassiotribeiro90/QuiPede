import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:quipede/app/di/dependencies.dart';
import '../../enderecos/bloc/endereco_cubit.dart';
import '../../enderecos/bloc/endereco_state.dart';
import 'endereco_confirmacao_page.dart';
import '../../../../shared/widgets/responsive_page_scaffold.dart';

class CepInputPage extends StatefulWidget {
  const CepInputPage({super.key});

  @override
  State<CepInputPage> createState() => _CepInputPageState();
}

class _CepInputPageState extends State<CepInputPage> {
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
    return BlocProvider.value(
      value: getIt<EnderecoCubit>(),
      child: BlocListener<EnderecoCubit, EnderecoState>(
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
                builder: (_) => BlocProvider.value(
                  value: getIt<EnderecoCubit>(),
                  child: EnderecoConfirmacaoPage(
                    endereco: endereco,
                    latitude: 0.0,
                    longitude: 0.0,
                  ),
                ),
              ),
            ).then((result) {
              print('🔙 [CepInputPage] Retorno da EnderecoConfirmacaoPage: $result');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  if (result == true) {
                    Navigator.pop(context, true);
                  } else {
                    Navigator.pop(context, false);
                  }
                }
              });
            });
          }
          if (state is EnderecoOperacaoSucesso) {
            print('✅ [CepInputPage] EnderecoOperacaoSucesso recebido!');
            setState(() => _isLoading = false);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.pop(context, true);
              }
            });
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
                      decoration: InputDecoration(
                        labelText: 'CEP',
                        hintText: 'Ex: 12345-678',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.mail_outline),
                        counterText: '',
                      ),
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
                            : const Text(
                          'Buscar CEP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ),
        ),
      ),
    );
  }
}