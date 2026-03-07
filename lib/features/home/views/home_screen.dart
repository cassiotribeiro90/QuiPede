import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../loja/bloc/loja_cubit.dart';
import '../../loja/bloc/loja_state.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LojaCubit>().listarLojas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuiGestor - Lojas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text('Menu QuiGestor', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Lojas'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Criar Nova Loja'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/criar-loja');
              },
            ),
          ],
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
            if (state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message!)),
              );
            }
          } else if (state is AuthTokenExpiringSoon) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sua sessão expirará em ${state.secondsRemaining} segundos!'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        child: BlocBuilder<LojaCubit, LojaState>(
          builder: (context, state) {
            if (state is LojaLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LojasLoaded) {
              if (state.lojas.isEmpty) {
                return const Center(child: Text('Nenhuma loja cadastrada.'));
              }
              return RefreshIndicator(
                onRefresh: () => context.read<LojaCubit>().listarLojas(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.lojas.length,
                  itemBuilder: (context, index) {
                    final loja = state.lojas[index];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.store)),
                        title: Text(loja['nome'] ?? 'Sem nome'),
                        subtitle: Text(loja['cnpj'] ?? 'Sem CNPJ'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Detalhes da loja
                        },
                      ),
                    );
                  },
                ),
              );
            } else if (state is LojaError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error, style: const TextStyle(color: Colors.red)),
                    ElevatedButton(
                      onPressed: () => context.read<LojaCubit>().listarLojas(),
                      child: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Bem-vindo ao QuiGestor'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/criar-loja'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
