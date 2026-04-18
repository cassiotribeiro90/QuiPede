import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quipede/shared/api/api_client.dart';
import 'package:quipede/app/di/dependencies.dart';
import 'package:quipede/app/core/utils/masks.dart';
import 'package:quipede/app/routes/app_routes.dart';
import 'package:quipede/app/modules/home/bloc/localizacao_cubit.dart';
import 'package:quipede/app/modules/home/services/localizacao_service.dart';
import 'widgets/endereco_card.dart';

class CepInputPage extends StatefulWidget {
  const CepInputPage({super.key});

  @override
  State<CepInputPage> createState() => _CepInputPageState();
}

class _CepInputPageState extends State<CepInputPage> {
  final _cepController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _localizacaoService = LocalizacaoService(getIt<ApiClient>());
  
  Map<String, dynamic>? _enderecoEncontrado;
  bool _isLoading = false;

  @override
  void dispose() {
    _cepController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) return;

    setState(() => _isLoading = true);
    try {
      final response = await _localizacaoService.buscarCep(cep);
      if (response['success'] == true) {
        setState(() {
          _enderecoEncontrado = response['data'];
        });
      } else {
        _showError(response['message'] ?? 'CEP não encontrado.');
      }
    } catch (e) {
      _showError('Erro ao buscar CEP.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _confirmarEndereco() {
    if (_enderecoEncontrado == null) return;
    if (_numeroController.text.isEmpty) {
      _showError('Informe o número.');
      return;
    }

    context.read<LocalizacaoCubit>().definirLocalizacaoManual(
      latitude: (_enderecoEncontrado!['latitude'] as num).toDouble(),
      longitude: (_enderecoEncontrado!['longitude'] as num).toDouble(),
      enderecoFormatado: '${_enderecoEncontrado!['logradouro']}, ${_numeroController.text}',
    );
    
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informar CEP')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cepController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CepInputFormatter(),
              ],
              decoration: InputDecoration(
                labelText: 'CEP',
                hintText: '00000-000',
                suffixIcon: _isLoading 
                  ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                  : IconButton(icon: const Icon(Icons.search), onPressed: _buscarCep),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.replaceAll(RegExp(r'\D'), '').length == 8) _buscarCep();
              },
            ),
            const SizedBox(height: 20),
            if (_enderecoEncontrado != null) ...[
              EnderecoCard(
                logradouro: _enderecoEncontrado!['logradouro'] ?? '',
                bairro: _enderecoEncontrado!['bairro'] ?? '',
                cidade: _enderecoEncontrado!['cidade'] ?? '',
                uf: _enderecoEncontrado!['uf'] ?? '',
                cep: _enderecoEncontrado!['cep'] ?? '',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _numeroController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Número', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _complementoController,
                      decoration: const InputDecoration(labelText: 'Complemento', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _confirmarEndereco,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('CONFIRMAR ENDEREÇO'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
