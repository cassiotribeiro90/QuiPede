/// Enum para o status de funcionamento da loja.
enum StatusLoja {
  aberto,
  fechado,
}

/// Enum para os tipos de pagamento aceitos.
enum TipoPagamento {
  credito,
  debito,
  pix,
  dinheiro,
  vr, // Vale Refeição
}

/// Enum para as principais categorias de lojas.
enum CategoriaTipo {
  hamburgueria,
  pizzaria,
  japonesa,
  brasileira,
  sorvete,
  bebidas,
  saude,
  petiscos,
  outros, // Categoria genérica
}

/// Enum para os tipos de ordenação da lista de lojas.
enum OrdenacaoTipo {
  padrao,
  nota,
  distancia,
}

// Helper para adicionar funcionalidades ao enum CategoriaTipo
extension CategoriaHelpers on CategoriaTipo {
  String get displayName => name[0].toUpperCase() + name.substring(1);

  String get emoji {
    switch (this) {
      case CategoriaTipo.hamburgueria:
        return '🍔';
      case CategoriaTipo.pizzaria:
        return '🍕';
      case CategoriaTipo.japonesa:
        return '🍣';
      case CategoriaTipo.brasileira:
        return '🇧🇷';
      case CategoriaTipo.sorvete:
        return '🍦';
      case CategoriaTipo.bebidas:
        return '🥤';
      case CategoriaTipo.saude:
        return '🥗';
      case CategoriaTipo.petiscos:
        return '🥨';
      default:
        return '🍽️';
    }
  }
}
