import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/api/api_service.dart';
import 'loja_state.dart';

class LojaCubit extends Cubit<LojaState> {
  final ApiService _apiService;

  LojaCubit(this._apiService) : super(LojaInitial());

  Future<void> listarLojas() async {
    emit(LojaLoading());
    try {
      final response = await _apiService.get('/lojas');
      emit(LojasLoaded(response.data));
    } catch (e) {
      emit(LojaError(e.toString()));
    }
  }

  Future<void> criarLoja(Map<String, dynamic> dadosLoja) async {
    emit(LojaLoading());
    try {
      await _apiService.post('/lojas', data: dadosLoja);
      emit(LojaSuccess('Loja criada com sucesso!'));
      listarLojas(); // Atualiza a lista após criar
    } catch (e) {
      emit(LojaError(e.toString()));
    }
  }

  Future<void> editarLoja(int id, Map<String, dynamic> dadosLoja) async {
    emit(LojaLoading());
    try {
      await _apiService.put('/lojas/$id', data: dadosLoja);
      emit(LojaSuccess('Loja atualizada com sucesso!'));
      listarLojas();
    } catch (e) {
      emit(LojaError(e.toString()));
    }
  }

  Future<void> deletarLoja(int id) async {
    emit(LojaLoading());
    try {
      await _apiService.delete('/lojas/$id');
      emit(LojaSuccess('Loja removida com sucesso!'));
      listarLojas();
    } catch (e) {
      emit(LojaError(e.toString()));
    }
  }
}
