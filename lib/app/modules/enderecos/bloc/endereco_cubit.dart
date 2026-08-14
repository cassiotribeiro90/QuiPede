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

  EnderecoCubit(this._repository) : super(EnderecoInitial());

  Future<void> carregarEnderecos({bool mostrarLoading = true}) async {
    if (_isCarregando) {
      debugPrint('⏳ [EnderecoCubit] Carregamento já em andamento, ignorando...');
      return;
    }
    _isCarregando = true;

    try {
      final hasData = state is EnderecoLoaded && (state as EnderecoLoaded).enderecos.isNotEmpty;
      if (mostrarLoading && !hasData) {
        emit(EnderecoLoading());
      }

      final enderecos = await _repository.getEnderecos();

      if (!isClosed) {
        EnderecoModel? principal;
        try {
          principal = enderecos.firstWhere((e) => e.principal == true);
        } catch (_) {
          principal = enderecos.isNotEmpty ? enderecos.first : null;
        }

        debugPrint('📦 [EnderecoCubit] Endereços carregados: ${enderecos.length}');
        for (var e in enderecos) {
          debugPrint('📦 [EnderecoCubit] Endereço: ${e.logradouro}, ${e.numero}, principal=${e.principal}');
        }

        emit(EnderecoLoaded(enderecos, enderecoPrincipal: principal));
      }
    } catch (e) {
      if (!isClosed) {
        debugPrint('❌ [EnderecoCubit] Erro ao carregar endereços: $e');
        emit(EnderecoError(e.toString()));
      }
    } finally {
      _isCarregando = false;
    }
  }

  Future<void> criarEndereco(EnderecoModel endereco) async {
    try {
      debugPrint('🚀 [EnderecoCubit] Criando endereço: ${endereco.enderecoResumido}');

      final result = await _repository.criarEndereco(endereco);

      if (!isClosed) {
        final token = result['token'];
        final usuarioJson = result['usuario'];

        if (token != null && usuarioJson != null) {
          debugPrint('🔑 [EnderecoCubit] Token de convidado detectado. Notificando AuthCubit...');
          getIt<AuthCubit>().onEnderecoCriadoComToken(token, usuarioJson);
        }

        final enderecoData = result['endereco'];

        if (enderecoData != null && enderecoData is Map<String, dynamic>) {
          final novo = EnderecoModel.fromJson(enderecoData);
          debugPrint('✅ [EnderecoCubit] Endereço criado: ID ${novo.id}');

          // Atualiza lista local
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
            await carregarEnderecos(mostrarLoading: false);
          }

          // ✅ Emite estado específico de sucesso
          if (!isClosed) {
            emit(EnderecoCriado(novo));
          }
        } else {
          debugPrint('⚠️ [EnderecoCubit] Formato inesperado, recarregando...');
          await carregarEnderecos(mostrarLoading: false);
          if (!isClosed && state is EnderecoLoaded) {
            final loaded = state as EnderecoLoaded;
            if (loaded.enderecos.isNotEmpty) {
              emit(EnderecoCriado(loaded.enderecos.last));
            }
          }
        }
      }
    } catch (e) {
      if (!isClosed) {
        debugPrint('❌ [EnderecoCubit] Erro ao criar endereço: $e');
        emit(EnderecoError(e.toString()));
      }
    }
  }

  Future<void> atualizarEndereco(EnderecoModel endereco) async {
    try {
      debugPrint('🔄 [EnderecoCubit] Atualizando endereço ID ${endereco.id}');

      final atualizado = await _repository.atualizarEndereco(endereco);

      if (!isClosed) {
        debugPrint('✅ [EnderecoCubit] Endereço atualizado: ID ${atualizado.id}');

        // Atualiza lista local
        final currentState = state;
        if (currentState is EnderecoLoaded) {
          final index = currentState.enderecos.indexWhere((e) => e.id == atualizado.id);
          if (index != -1) {
            final novosEnderecos = [...currentState.enderecos];
            novosEnderecos[index] = atualizado;

            EnderecoModel? principal;
            try {
              principal = novosEnderecos.firstWhere((e) => e.principal == true);
            } catch (_) {
              principal = novosEnderecos.isNotEmpty ? novosEnderecos.first : null;
            }

            emit(EnderecoLoaded(novosEnderecos, enderecoPrincipal: principal));
          }
        }

        // ✅ Emite estado específico de sucesso
        if (!isClosed) {
          emit(EnderecoAtualizado(atualizado));
        }
      }
    } catch (e) {
      if (!isClosed) {
        debugPrint('❌ [EnderecoCubit] Erro ao atualizar endereço: $e');
        await carregarEnderecos(mostrarLoading: false);
        emit(EnderecoError(e.toString()));
      }
    }
  }

  Future<void> deletarEndereco(int id) async {
    try {
      debugPrint('🗑️ [EnderecoCubit] Excluindo endereço ID $id');

      await _repository.deletarEndereco(id);

      if (!isClosed) {
        debugPrint('✅ [EnderecoCubit] Endereço excluído: ID $id');

        // Atualiza lista local
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
        } else {
          await carregarEnderecos(mostrarLoading: false);
        }

        // ✅ Emite estado específico de sucesso
        if (!isClosed) {
          emit(EnderecoExcluido(id));
        }
      }
    } catch (e) {
      if (!isClosed) {
        debugPrint('❌ [EnderecoCubit] Erro ao excluir endereço: $e');
        await carregarEnderecos(mostrarLoading: false);
        emit(EnderecoError(e.toString()));
      }
    }
  }

  Future<void> definirPrincipal(int id) async {
    try {
      debugPrint('⭐ [EnderecoCubit] Definindo endereço $id como selecionado');

      final enderecosAtualizados = await _repository.definirPrincipal(id);

      if (!isClosed) {
        EnderecoModel? principal;
        try {
          principal = enderecosAtualizados.firstWhere((e) => e.principal == true);
        } catch (_) {
          principal = enderecosAtualizados.isNotEmpty ? enderecosAtualizados.first : null;
        }

        debugPrint('✅ [EnderecoCubit] Lista sincronizada: ${enderecosAtualizados.length} endereços');
        emit(EnderecoLoaded(enderecosAtualizados, enderecoPrincipal: principal));

        // ✅ Emite estado específico de sucesso
        if (!isClosed) {
          emit(EnderecoPrincipalDefinido(id));
        }
      }
    } catch (e) {
      if (!isClosed) {
        debugPrint('❌ [EnderecoCubit] Erro ao definir principal: $e');
        await carregarEnderecos(mostrarLoading: false);
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

  void substituirEnderecos(List<EnderecoModel> novosEnderecos) {
    if (isClosed) return;
    
    EnderecoModel? principal;
    try {
      principal = novosEnderecos.firstWhere((e) => e.principal == true);
    } catch (_) {
      principal = novosEnderecos.isNotEmpty ? novosEnderecos.first : null;
    }
    
    emit(EnderecoLoaded(novosEnderecos, enderecoPrincipal: principal));
  }

  void resetStatus() {
    if (!isClosed) {
      final currentState = state;
      if (currentState is EnderecoError) {
        carregarEnderecos(mostrarLoading: false);
      }
    }
  }
}
