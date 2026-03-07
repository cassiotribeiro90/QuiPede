import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import '../../../models/avaliacao_model.dart';
import 'loja_avaliacoes_state.dart';

class LojaAvaliacoesCubit extends Cubit<LojaAvaliacoesState> {
  final int lojaId;

  LojaAvaliacoesCubit(this.lojaId) : super(LojaAvaliacoesInitial());

  Future<void> loadAvaliacoes() async {
    try {
      emit(LojaAvaliacoesLoading());

      final String jsonString = await rootBundle.loadString('lib/app/assets/data/avaliacoes.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> todasAvaliacoesJson = jsonData['avaliacoes'];

      // Filtra as avaliações para pegar apenas as da loja selecionada
      final List<Avaliacao> avaliacoesDaLoja = todasAvaliacoesJson
          .map((json) => Avaliacao.fromJson(json))
          .where((avaliacao) => avaliacao.lojaId == lojaId)
          .toList();

      emit(LojaAvaliacoesLoaded(avaliacoesDaLoja));
    } catch (e) {
      emit(LojaAvaliacoesError('Falha ao carregar as avaliações: ${e.toString()}'));
    }
  }
}
