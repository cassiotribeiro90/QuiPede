import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// Parte 1: Definir os Estados
abstract class SplashState extends Equatable {
  const SplashState();
  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashNavigateToHome extends SplashState {}

// Parte 2: Criar o Cubit
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  void loadAndNavigate() {
    // Simula um carregamento e depois emite o estado para navegar
    Future.delayed(const Duration(seconds: 2), () {
      emit(SplashNavigateToHome());
    });
  }
}
