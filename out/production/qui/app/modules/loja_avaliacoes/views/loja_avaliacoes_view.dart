import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/loja_avaliacoes_cubit.dart';
import '../cubit/loja_avaliacoes_state.dart';

class LojaAvaliacoesView extends StatefulWidget {
  const LojaAvaliacoesView({super.key});

  @override
  State<LojaAvaliacoesView> createState() => _LojaAvaliacoesViewState();
}

class _LojaAvaliacoesViewState extends State<LojaAvaliacoesView> {
  @override
  void initState() {
    super.initState();
    context.read<LojaAvaliacoesCubit>().loadAvaliacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliações da Loja'),
      ),
      body: BlocBuilder<LojaAvaliacoesCubit, LojaAvaliacoesState>(
        builder: (context, state) {
          if (state is LojaAvaliacoesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LojaAvaliacoesError) {
            return Center(child: Text(state.message));
          } else if (state is LojaAvaliacoesLoaded) {
            if (state.avaliacoes.isEmpty) {
              return const Center(child: Text('Esta loja ainda não tem avaliações.'));
            }
            return ListView.builder(
              itemCount: state.avaliacoes.length,
              itemBuilder: (context, index) {
                final avaliacao = state.avaliacoes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(avaliacao.nomeUsuario, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < avaliacao.nota ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(avaliacao.comentario),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
