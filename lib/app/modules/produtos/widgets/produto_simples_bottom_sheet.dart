import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../di/dependencies.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../../auth/bloc/auth_state.dart';
import '../../carrinho/bloc/carrinho_cubit.dart';

class ProdutoSimplesBottomSheet extends StatefulWidget {
  final dynamic produto;
  final int lojaId;
  final int? initialQuantidade;
  final String? initialObservacao;

  const ProdutoSimplesBottomSheet({
    super.key,
    required this.produto,
    required this.lojaId,
    this.initialQuantidade,
    this.initialObservacao,
  });

  @override
  State<ProdutoSimplesBottomSheet> createState() => _ProdutoSimplesBottomSheetState();
}

class _ProdutoSimplesBottomSheetState extends State<ProdutoSimplesBottomSheet> {
  late int _quantidade;
  bool _isAdding = false;
  late final TextEditingController _observacaoController;

  @override
  void initState() {
    super.initState();
    _quantidade = widget.initialQuantidade ?? 1;
    _observacaoController = TextEditingController(text: widget.initialObservacao);
  }

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CarrinhoCubit, CarrinhoState>(
      listener: (context, state) {
        if (kDebugMode) {
          print('📥 [ProdutoModal] Novo estado recebido: ${state.runtimeType}');
        }

        if (state is CarrinhoConflitoLoja) {
          if (kDebugMode) print('⚠️ [ProdutoModal] Conflito de loja detectado');
          setState(() => _isAdding = false);
          _mostrarDialogoConflito(state);
        } else if (state is CarrinhoLoaded && _isAdding) {
          if (kDebugMode) print('✅ [ProdutoModal] Sucesso ao adicionar ao carrinho');
          setState(() => _isAdding = false);
          Navigator.pop(context); // Sucesso: Fecha o modal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.produto.nome} adicionado ao carrinho!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is CarrinhoError && _isAdding) {
          if (kDebugMode) print('❌ [ProdutoModal] Erro ao adicionar: ${state.message}');
          // ✅ Se falhar (inclusive erro de conexão), resetamos o estado para o botão voltar a funcionar
          setState(() => _isAdding = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message), 
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'FECHAR',
                textColor: Colors.white,
                onPressed: () => Navigator.pop(context), // Permite fechar pelo SnackBar
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProdutoHeader(),
                    if (widget.produto.descricao != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.produto.descricao,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                    const SizedBox(height: 20),
                    TextField(
                      controller: _observacaoController,
                      enabled: !_isAdding,
                      decoration: InputDecoration(
                        hintText: 'Alguma observação?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    _buildQuantidadeSelector(),
                    const SizedBox(height: 24),
                    _buildBotaoAdicionar(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProdutoHeader() {
    final produto = widget.produto;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (produto.imagem != null && produto.imagem.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              produto.imagem,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          )
        else
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fastfood, size: 40, color: Colors.grey),
          ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                produto.nome ?? 'Produto',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'R\$ ${(produto.preco ?? 0).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantidadeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Quantidade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Row(
          children: [
            IconButton(
              onPressed: _isAdding
                  ? null
                  : (_quantidade > 1
                      ? () => setState(() => _quantidade--)
                      : null),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _isAdding
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('$_quantidade', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              onPressed: _isAdding ? null : () => setState(() => _quantidade++),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBotaoAdicionar() {
    final precoTotal = (widget.produto.preco ?? 0) * _quantidade;
    
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isAdding ? null : _handleAdicionar,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: _isAdding
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                  SizedBox(width: 12),
                  Text('Adicionando...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              )
            : Text('Adicionar • R\$ ${precoTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _handleAdicionar() async {
    final authCubit = getIt<AuthCubit>();
    if (authCubit.state is! AuthAuthenticated) {
      if (kDebugMode) print('ℹ️ [ProdutoModal] Usuário não autenticado, solicitando login');
      Navigator.pop(context, {
        'requestLogin': true,
        'produto': widget.produto,
        'lojaId': widget.lojaId,
        'quantidade': _quantidade,
        'observacao': _observacaoController.text.trim(),
      });
      return;
    }

    if (kDebugMode) {
      print('📤 [ProdutoModal] Adicionando item: produtoId=${widget.produto.id}, quantidade=$_quantidade, observacao=${_observacaoController.text.trim()}');
    }

    setState(() => _isAdding = true);

    context.read<CarrinhoCubit>().adicionarItem(
      produtoId: widget.produto.id,
      quantidade: _quantidade,
      observacao: _observacaoController.text.trim().isNotEmpty
          ? _observacaoController.text.trim()
          : null,
      applyDebounce: false
    );
  }

  void _mostrarDialogoConflito(CarrinhoConflitoLoja conflito) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Carrinho br outra loja'),
        content: Text(conflito.mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (kDebugMode) print('🧹 [ProdutoModal] Limpando carrinho e adicionando novo item');
              Navigator.pop(dialogContext);
              setState(() => _isAdding = true);
              await context.read<CarrinhoCubit>().limparEAdicionar(
                produtoId: widget.produto.id,
                quantidade: _quantidade,
                observacao: _observacaoController.text.trim().isNotEmpty 
                    ? _observacaoController.text.trim() 
                    : null,
              );
            },
            child: const Text('Limpar e adicionar'),
          ),
        ],
      ),
    );
  }
}
