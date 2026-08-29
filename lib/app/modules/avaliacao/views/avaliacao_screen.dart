import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quipede/app/core/theme/app_colors.dart';
import 'package:quipede/app/modules/avaliacao/bloc/avaliacao_bloc.dart';
import 'package:quipede/app/shared/widgets/star_rating.dart';
import 'package:quipede/app/shared/widgets/rounded_button.dart';

class AvaliacaoScreen extends StatefulWidget {
  final Map<String, dynamic>? pedidoData;
  final Map<String, dynamic>? lojaData;
  final List<dynamic>? produtosData;

  const AvaliacaoScreen({
    Key? key,
    this.pedidoData,
    this.lojaData,
    this.produtosData,
  }) : super(key: key);

  @override
  State<AvaliacaoScreen> createState() => _AvaliacaoScreenState();
}

class _AvaliacaoScreenState extends State<AvaliacaoScreen> {
  // 🔥 Estado da avaliação da loja
  double _notaLoja = 0;
  final TextEditingController _comentarioLojaController = TextEditingController();
  
  // 🔥 Estado da avaliação dos produtos
  Map<int, double> _notasProdutos = {};
  Map<int, TextEditingController> _comentarioProdutosControllers = {};
  Map<int, bool> _produtosSelecionados = {};

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initProdutos();
  }

  void _initProdutos() {
    final produtos = widget.produtosData ?? [];
    for (var produto in produtos) {
      final id = produto['id'] as int;
      _notasProdutos[id] = 0;
      _comentarioProdutosControllers[id] = TextEditingController();
      _produtosSelecionados[id] = false;
    }
  }

  @override
  void dispose() {
    _comentarioLojaController.dispose();
    for (var controller in _comentarioProdutosControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AvaliacaoBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Avalie seu pedido'),
          centerTitle: true,
          backgroundColor: AppColors.chatPrimary,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildLojaAvaliacao(),
                const SizedBox(height: 24),
                _buildProdutosAvaliacao(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pedido #${widget.pedidoData?['codigo'] ?? widget.pedidoData?['id']}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Loja: ${widget.lojaData?['nome'] ?? 'Loja'}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.chatPastel.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.chatPrimary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Pedido entregue!',
                style: TextStyle(color: AppColors.chatPrimary, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                widget.pedidoData?['data_entrega'] ?? '',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLojaAvaliacao() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.chatPastel.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.store, color: AppColors.chatPrimary, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.lojaData?['nome'] ?? 'Loja',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Avalie sua experiência com a loja',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StarRating(
            rating: _notaLoja,
            size: 32,
            interactive: true,
            onRatingUpdate: (value) {
              setState(() => _notaLoja = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _comentarioLojaController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'O que você achou da loja?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.chatPrimary),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProdutosAvaliacao() {
    final produtos = widget.produtosData ?? [];
    
    if (produtos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📦 Avalie os produtos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque em um produto para avaliá-lo individualmente',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ...produtos.map((produto) => _buildProdutoItem(produto)),
        ],
      ),
    );
  }

  Widget _buildProdutoItem(Map<String, dynamic> produto) {
    final id = produto['id'] as int;
    final bool isSelected = _produtosSelecionados[id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.chatPrimary : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _produtosSelecionados[id] = !isSelected;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  // Ícone/Imagem do produto
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      image: produto['imagem'] != null
                          ? DecorationImage(
                              image: NetworkImage(produto['imagem']),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: produto['imagem'] == null
                        ? const Icon(Icons.fastfood, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produto['nome'] ?? 'Produto',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${produto['quantidade']}x - R\$ ${produto['preco_unitario']?.toStringAsFixed(2) ?? '0,00'}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        _produtosSelecionados[id] = value ?? false;
                      });
                    },
                    activeColor: AppColors.chatPrimary,
                  ),
                ],
              ),
              if (isSelected) ...[
                const Divider(),
                Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Nota:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 12),
                        StarRating(
                          rating: _notasProdutos[id] ?? 0,
                          size: 24,
                          interactive: true,
                          onRatingUpdate: (value) {
                            setState(() {
                              _notasProdutos[id] = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _comentarioProdutosControllers[id],
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'O que achou deste produto?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.chatPrimary),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isEnabled = _notaLoja > 0 && !_isSubmitting;

    return RoundedButton(
      label: _isSubmitting ? 'Enviando...' : 'Enviar Avaliação',
      isLoading: _isSubmitting,
      isEnabled: isEnabled,
      onPressed: _submeterAvaliacao,
      backgroundColor: AppColors.chatPrimary,
      width: double.infinity,
    );
  }

  // ================================================================
  // 🔥 MÉTODOS DE AÇÃO
  // ================================================================

  void _submeterAvaliacao() async {
    if (_notaLoja == 0) {
      _showSnackbar('Por favor, avalie a loja', Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    final bloc = context.read<AvaliacaoBloc>();

    try {
      // 1. Envia avaliação da loja
      final lojaData = {
        'loja_id': widget.lojaData?['id'],
        'pedido_id': widget.pedidoData?['id'],
        'nota': _notaLoja.toInt(),
        'comentario': _comentarioLojaController.text.trim(),
        'status': 'aprovado',
      };

      bloc.add(CriarAvaliacao(lojaData));

      // 2. Envia avaliações dos produtos selecionados
      final produtos = widget.produtosData ?? [];
      for (var produto in produtos) {
        final id = produto['id'] as int;
        if (_produtosSelecionados[id] == true) {
          final nota = _notasProdutos[id] ?? 0;
          if (nota > 0) {
            final produtoData = {
              'produto_id': id,
              'loja_id': widget.lojaData?['id'],
              'pedido_id': widget.pedidoData?['id'],
              'nota': nota.toInt(),
              'comentario': _comentarioProdutosControllers[id]?.text.trim() ?? '',
              'status': 'aprovado',
            };
            bloc.add(CriarAvaliacao(produtoData));
          }
        }
      }

      _showSnackbar('✅ Avaliação enviada com sucesso!', AppColors.chatPrimary);

      // Volta para a tela inicial após 2 segundos
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      });

    } catch (e) {
      _showSnackbar('❌ Erro ao enviar avaliação: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
