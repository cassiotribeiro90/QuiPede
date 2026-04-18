import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../routes/app_routes.dart';
import '../bloc/localizacao_cubit.dart';
import 'widgets/endereco_card.dart';

class EnderecoConfirmacaoPage extends StatefulWidget {
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
  State<EnderecoConfirmacaoPage> createState() => _EnderecoConfirmacaoPageState();
}

class _EnderecoConfirmacaoPageState extends State<EnderecoConfirmacaoPage> {
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
      enderecoFormatado: '${widget.endereco['logradouro'] ?? widget.endereco['descricao']}, ${_numeroController.text}',
    );
    // Aqui poderíamos salvar o endereço formatado no SharedPreferences via Cubit
    Navigator.pushNamedAndRemoveUntil(context, Routes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Endereço')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('CONFIRMAR E CONTINUAR', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
