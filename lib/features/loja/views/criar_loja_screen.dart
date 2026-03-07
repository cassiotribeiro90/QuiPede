import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/loja_cubit.dart';
import '../bloc/loja_state.dart';

class CriarLojaScreen extends StatefulWidget {
  const CriarLojaScreen({super.key});

  @override
  State<CriarLojaScreen> createState() => _CriarLojaScreenState();
}

class _CriarLojaScreenState extends State<CriarLojaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _enderecoController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<LojaCubit>().criarLoja({
        'nome': _nomeController.text,
        'cnpj': _cnpjController.text,
        'endereco': _enderecoController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Loja')),
      body: BlocConsumer<LojaCubit, LojaState>(
        listener: (context, state) {
          if (state is LojaSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context);
          } else if (state is LojaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(labelText: 'Nome da Loja'),
                    validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cnpjController,
                    decoration: const InputDecoration(labelText: 'CNPJ'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.length < 14 ? 'CNPJ inválido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _enderecoController,
                    decoration: const InputDecoration(labelText: 'Endereço Completo'),
                    validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: state is LojaLoading ? null : _submit,
                    child: state is LojaLoading
                        ? const CircularProgressIndicator()
                        : const Text('CRIAR LOJA'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
