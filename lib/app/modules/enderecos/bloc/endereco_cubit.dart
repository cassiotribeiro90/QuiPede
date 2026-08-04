import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../di/dependencies.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../models/endereco_model.dart';
import '../repositories/endereco_repository.dart';
import 'endereco_state.dart';

class EnderecoCubit extends Cubit<EnderecoState> {
  final EnderecoRepository _repository;
  bool _isCarregando = false;
  bool _operacaoConcluida = false; // 🔥 NOVA FLAG PARA EVITAR DUPLICATAS

  EnderecoCubit(this._repository) : super(EnderecoInitial());

  Future<void> carregarEnderecos() async {
    if (_isCarregando) {
      debugPrint('⏳ [EnderecoCubit] Carregamento já em andamento, ignorando...');
      return;
    }
    _isCarregando = true;

    try {
      emit(EnderecoLoading());
      final enderecos = await _repository.getEnderecos();

      if (!isClosed) {
        EnderecoModel? principal;
        try {
          principal = enderecos.firstWhere((e) => e.principal == true);
        } catch (_) {
          principal = enderecos.isNotEmpty ? enderecos.first : null;
        }

        print('🔍 [EnderecoCubit] Endereços carregados: ${enderecos.length}');
        emit(EnderecoLoaded(enderecos, enderecoPrincipal: principal));
      }
    } catch (e) {
      if (!isClosed) {
        print('❌ [EnderecoCubit] Erro ao carregar endereços: $e');
        emit(EnderecoError(e.toString()));
      }
    } finally {
      _isCarregando = false;
    }
  }

  /// Cria um novo endereço
  Future<void> criarEndereco(EnderecoModel endereco) async {
    if (_operacaoConcluida) {
      debugPrint('⚠️ [EnderecoCubit] Operação já concluída ou em andamento, ignorando...');
      return;
    }
    _operacaoConcluida = true;

    try {
      print('🚀 [EnderecoCubit] Criando endereço: ${endereco.enderecoResumido}');
      emit(EnderecoLoading());
      final result = await _repository.criarEndereco(endereco);

      if (!isClosed) {
        // 🔥 CAPTURAR TOKEN E USUÁRIO (CONVIDADO) RETORNADOS PELO BACKEND
        final token = result['token'];
        final usuarioJson = result['usuario'];

        if (token != null && usuarioJson != null) {
          debugPrint('🔑 [EnderecoCubit] Token de convidado detectado no retorno. Atualizando AuthCubit...');
          getIt<AuthCubit>().onEnderecoCriadoComToken(token, usuarioJson);
        }

        final enderecoData = result['endereco'];

        if (enderecoData != null && enderecoData is Map<String, dynamic>) {
          final novo = EnderecoModel.fromJson(enderecoData);
          print('✅ [EnderecoCubit] Endereço criado com sucesso: ID ${novo.id}');

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
          } else {
            await carregarEnderecos();
          }

          if (!isClosed) {
            emit(const EnderecoOperacaoSucesso('Endereço adicionado com sucesso!'));
          }
        } else {
          print('⚠️ [EnderecoCubit] Endereço criado, mas dados não retornados no formato esperado. Recarregando...');
          await carregarEnderecos();
          if (!isClosed) {
            emit(const EnderecoOperacaoSucesso('Endereço adicionado com sucesso!'));
          }
        }
      }
    } catch (e) {
      _operacaoConcluida = false; // 🔥 PERMITE NOVA TENTATIVA EM CASO DE ERRO
      if (!isClosed) {
        print('❌ [EnderecoCubit] Erro ao criar endereço: $e');
        emit(EnderecoError(e.toString()));
      }
    }
  }

  Future<void> atualizarEndereco(EnderecoModel endereco) async {
    _operacaoConcluida = false;
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
    _operacaoConcluida = false;
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
    _operacaoConcluida = false;
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
    _operacaoConcluida = false;
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

  void resetarOperacao() {
    _operacaoConcluida = false;
  }

  void resetStatus() {
    _operacaoConcluida = false;
    if (!isClosed) {
      final currentState = state;
      if (currentState is EnderecoError || currentState is EnderecoOperacaoSucesso) {
        carregarEnderecos();
      }
    }
  }
}
