import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/endereco_model.dart';
import '../repositories/endereco_repository.dart';
import 'endereco_state.dart';

class EnderecoCubit extends Cubit<EnderecoState> {
  final EnderecoRepository _repository;

  EnderecoCubit(this._repository) : super(EnderecoInitial());

  Future<void> carregarEnderecos() async {
    try {
      emit(EnderecoLoading());
      final enderecos = await _repository.getEnderecos();
      
      // 🔥 GARANTE QUE SÓ EMITE SE O WIDGET AINDA ESTIVER MONTADO
      if (!isClosed) {
        EnderecoModel? principal;
        try {
          principal = enderecos.firstWhere((e) => e.principal == true);
        } catch (_) {
          principal = enderecos.isNotEmpty ? enderecos.first : null;
        }
        emit(EnderecoLoaded(enderecos, enderecoPrincipal: principal));
      }
    } catch (e) {
      if (!isClosed) {
        emit(EnderecoError(e.toString()));
      }
    }
  }

  Future<void> criarEndereco(EnderecoModel endereco) async {
    try {
      emit(EnderecoLoading());
      final novo = await _repository.criarEndereco(endereco);
      
      if (!isClosed) {
        final currentState = state;
        if (currentState is EnderecoLoaded) {
          final novosEnderecos = [...currentState.enderecos, novo];
          EnderecoModel? principal;
          try {
            principal = novosEnderecos.firstWhere((e) => e.principal == true);
          } catch (_) {
            principal = novosEnderecos.isNotEmpty ? novosEnderecos.first : null;
          }
          emit(EnderecoLoaded(novosEnderecos, enderecoPrincipal: principal));
          emit(const EnderecoOperacaoSucesso('Endereço adicionado com sucesso!'));
        } else {
          await carregarEnderecos();
          if (!isClosed) {
            emit(const EnderecoOperacaoSucesso('Endereço adicionado com sucesso!'));
          }
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(EnderecoError(e.toString()));
      }
    }
  }

  Future<void> atualizarEndereco(EnderecoModel endereco) async {
    try {
      emit(EnderecoLoading());
      await _repository.atualizarEndereco(endereco);
      if (!isClosed) {
        await carregarEnderecos();
        if (!isClosed) {
          emit(const EnderecoOperacaoSucesso('Endereço atualizado com sucesso!'));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(EnderecoError(e.toString()));
      }
    }
  }

  Future<void> deletarEndereco(int id) async {
    try {
      emit(EnderecoLoading());
      await _repository.deletarEndereco(id);
      
      if (!isClosed) {
        final currentState = state;
        if (currentState is EnderecoLoaded) {
          final novosEnderecos = currentState.enderecos.where((e) => e.id != id).toList();
          EnderecoModel? principal;
          try {
            principal = novosEnderecos.firstWhere((e) => e.principal == true);
          } catch (_) {
            principal = novosEnderecos.isNotEmpty ? novosEnderecos.first : null;
          }
          emit(EnderecoLoaded(novosEnderecos, enderecoPrincipal: principal));
          emit(const EnderecoOperacaoSucesso('Endereço removido com sucesso!'));
        } else {
          await carregarEnderecos();
          if (!isClosed) {
            emit(const EnderecoOperacaoSucesso('Endereço removido com sucesso!'));
          }
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(EnderecoError(e.toString()));
      }
    }
  }

  Future<void> definirPrincipal(int id) async {
    try {
      await _repository.definirPrincipal(id);
      if (!isClosed) {
        await carregarEnderecos();
        if (!isClosed) {
          emit(const EnderecoOperacaoSucesso('Endereço principal atualizado!'));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(EnderecoError(e.toString()));
      }
    }
  }

  Future<void> buscarCep(String cep) async {
    try {
      emit(EnderecoCepBuscando());
      final dados = await _repository.buscarCep(cep);
      if (!isClosed) {
        emit(EnderecoCepCarregado(dados));
      }
    } catch (e) {
      if (!isClosed) {
        emit(EnderecoError(e.toString()));
      }
    }
  }

  void resetStatus() {
    if (!isClosed) {
      final currentState = state;
      if (currentState is EnderecoError || currentState is EnderecoOperacaoSucesso) {
        carregarEnderecos();
      }
    }
  }
}
