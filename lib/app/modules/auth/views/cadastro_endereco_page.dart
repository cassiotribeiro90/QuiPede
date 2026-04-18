import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/core/utils/masks.dart';
import '../../../../shared/api/api_client.dart';
import '../../../../app_config.dart';
import '../../../di/dependencies.dart';
import '../../../routes/app_routes.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../models/cadastro_models.dart';

class CadastroEnderecoPage extends StatefulWidget {
  const CadastroEnderecoPage({super.key});

  @override
  State<CadastroEnderecoPage> createState() => _CadastroEnderecoPageState();
}

class _CadastroEnderecoPageState extends State<CadastroEnderecoPage> {
  final _formKey = GlobalKey<FormState>();
  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();
  final _apelidoController = TextEditingController();
  
  final _numeroFocusNode = FocusNode();
  bool _isLoadingCep = false;

  @override
  void dispose() {
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
    _apelidoController.dispose();
    _numeroFocusNode.dispose();
    super.dispose();
  }

  /// Busca o endereço pelo CEP, garantindo que apenas dígitos sejam enviados à API.
  Future<void> _buscarCep() async {
    // 1. Obtém o texto atual do campo (com máscara) e remove tudo que não for dígito
    final cepLimpo = _cepController.text.replaceAll(RegExp(r'\D'), '');
    
    // 2. Valida o comprimento do CEP limpo (8 dígitos)
    if (cepLimpo.length != 8) return;

    setState(() => _isLoadingCep = true);
    
    try {
      final apiClient = getIt<ApiClient>();
      
      // 3. Envia a requisição passando o valor limpo
      final response = await apiClient.get(
        AppConfig.BUSCAR_CEP, 
        queryParameters: {'cep': cepLimpo},
        requiresAuth: false
      );

      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        setState(() {
          _logradouroController.text = data['logradouro'] ?? '';
          _bairroController.text = data['bairro'] ?? '';
          _cidadeController.text = data['cidade'] ?? '';
          _ufController.text = data['uf'] ?? '';
          _complementoController.text = data['complemento'] ?? '';
        });
        // 4. Move o foco para o número após preencher
        _numeroFocusNode.requestFocus();
      } else {
        _showErrorSnackBar(response.data['message'] ?? 'CEP não encontrado.');
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao buscar CEP. Preencha manualmente.');
    } finally {
      if (mounted) setState(() => _isLoadingCep = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  void _finalizarCadastro(CadastroInfoModel info) {
    if (_formKey.currentState!.validate()) {
      // Garante o CEP limpo também no cadastro final
      final cepLimpo = _cepController.text.replaceAll(RegExp(r'\D'), '');

      final endereco = CadastroEnderecoModel(
        cep: cepLimpo,
        logradouro: _logradouroController.text.trim(),
        numero: _numeroController.text.trim(),
        complemento: _complementoController.text.trim(),
        bairro: _bairroController.text.trim(),
        cidade: _cidadeController.text.trim(),
        uf: _ufController.text.trim(),
        apelido: _apelidoController.text.trim().isEmpty ? null : _apelidoController.text.trim(),
      );

      final payload = {
        ...info.toJson(),
        ...endereco.toJson(),
      };

      context.read<AuthCubit>().cadastrar(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = ModalRoute.of(context)!.settings.arguments as CadastroInfoModel;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro - Etapa 2 de 2'),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LinearProgressIndicator(value: 1.0),
                const SizedBox(height: 32),
                Text(
                  'Endereço de Entrega',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Onde você deseja receber seus pedidos?'),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CepInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    labelText: 'CEP',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: _isLoadingCep 
                      ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
                      : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final clean = value.replaceAll(RegExp(r'\D'), '');
                    if (clean.length == 8) _buscarCep();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe o CEP';
                    if (value.replaceAll(RegExp(r'\D'), '').length != 8) return 'CEP deve ter 8 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _logradouroController,
                  decoration: const InputDecoration(
                    labelText: 'Logradouro (Rua, Av.)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Informe o logradouro' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _numeroController,
                        focusNode: _numeroFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Número',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _complementoController,
                        decoration: const InputDecoration(
                          labelText: 'Complemento',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _bairroController,
                  decoration: const InputDecoration(
                    labelText: 'Bairro',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Informe o bairro' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _cidadeController,
                        decoration: const InputDecoration(
                          labelText: 'Cidade',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'Informe a cidade' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _ufController,
                        decoration: const InputDecoration(
                          labelText: 'UF',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'UF' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _apelidoController,
                  decoration: const InputDecoration(
                    labelText: 'Apelido (Ex: Casa, Trabalho)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading || _isLoadingCep;
                    return ElevatedButton(
                      onPressed: isLoading ? null : () => _finalizarCadastro(info),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: (state is AuthLoading)
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('FINALIZAR CADASTRO', style: TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
