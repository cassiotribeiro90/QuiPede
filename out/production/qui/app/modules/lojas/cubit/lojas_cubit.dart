import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'lojas_state.dart';
import '../../../models/loja_model.dart';

class LojasCubit extends Cubit<LojasState> {
  LojasCubit() : super(LojasInitial());

  Future<void> loadLojas() async {
    try {
      emit(LojasLoading());

      final String jsonString = await rootBundle.loadString('lib/app/assets/data/lojas.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> lojasJson = jsonData['lojas'];
      final List<Loja> lojas = lojasJson.map((json) => Loja.fromJson(json)).toList();

      emit(LojasLoaded(lojas));
    } catch (e) {
      emit(LojasError('Falha ao carregar as lojas: ${e.toString()}'));
    }
  }
}
