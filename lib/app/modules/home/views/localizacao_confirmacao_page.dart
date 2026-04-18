import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../routes/app_routes.dart';
import '../bloc/localizacao_cubit.dart';
import 'widgets/endereco_card.dart';

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

  @override
  void dispose() {
    _numeroController.dispose();
    _complementoController.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (_numeroController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o número.'), backgroundColor: Colors.orange),
      );
      return;
    }
    
    context.read<LocalizacaoCubit>().definirLocalizacaoManual(
      latitude: widget.latitude,
      longitude: widget.longitude,
      enderecoFormatado: '${widget.endereco['logradouro']}, ${_numeroController.text}',
    );
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Localização')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
              uf: widget.endereco['uf'] ?? '',
              cep: widget.endereco['cep'] ?? '',
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _confirmar,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('CONFIRMAR E CONTINUAR'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tentar outra forma'),
            ),
          ],
        ),
      ),
    );
  }
}
