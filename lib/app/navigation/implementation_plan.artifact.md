# Plano de Implementação - Correção de Rotas de Detalhe do Pedido

Este plano visa corrigir a inconsistência nas rotas de navegação para o detalhe do pedido, garantindo que o caminho correto `/pedidos/detalhe/:id` seja utilizado em todos os lugares, preferencialmente através do `NavigationCubit` e das constantes de rotas.

## Propostas de Mudanças

### Navigation

#### [MODIFY] [navigation_cubit.dart](file:///C:/Users/cassi/projetos/quipede/lib/app/navigation/navigation_cubit.dart)
- Refatorar `goToPedidoDetalhe` para utilizar a constante `Routes.pedidoDetalhe`.

### Carrinho

#### [MODIFY] [carrinho_page.dart](file:///C:/Users/cassi/projetos/quipede/lib/app/modules/carrinho/views/carrinho_page.dart)
- Corrigir a navegação após a criação do pedido para usar `NavigationCubit.goToPedidoDetalhe` em vez de um caminho hardcoded incorreto (`/pedido/:id`).

## Plano de Verificação

### Verificação Manual
1. Abrir o carrinho, finalizar um pedido e verificar se a navegação para o detalhe ocorre corretamente.
2. Na tela de perfil, clicar em um pedido anterior e verificar se o detalhe abre corretamente.
