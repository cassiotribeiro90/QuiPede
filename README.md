markdown

# 🍔 QuiPede

App de delivery desenvolvido em Flutter com arquitetura limpa e BLoC.

![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?style=flat-square&logo=dart&logoColor=white)
![BLoC](https://img.shields.io/badge/BLoC-8.1+-29B6F6?style=flat-square&logo=bloc&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

---

## ✨ Features

- Lista de lojas com filtros por categoria
- Cardápio organizado por seções
- Sistema de avaliações com notas e comentários
- Carrinho de compras com cálculo automático
- Geolocalização para cálculo de distância
- Tema personalizado com cores da marca

---

## 🛠️ Tecnologias

| Camada | Tecnologia |
|--------|------------|
| UI | Flutter |
| Estado | BLoC / Cubit |
| Injeção de Dependência | GetIt |
| Requisições HTTP | Dio |
| Imagens | cached_network_image |
| Formatação | intl |
| Armazenamento Local | shared_preferences |

---

## Resumo Técnico do Projeto QuiPede

Stack: Flutter 3.x (Dart) no frontend, PHP 8.x com Yii2 no backend, banco MariaDB/MySQL. Gerenciamento de estado com flutter_bloc (Cubit) e injeção de dependências com GetIt. HTTP via Dio customizado no ApiClient. Navegação por rotas nomeadas (Navigator 1.0). Tema com AppThemeExtension e AppTextStyles (bodyLarge 20px, bodyMedium 18px, bodySmall 16px, caption 13px).

Estrutura de diretórios principal: lib/app/modules/ contém cada funcionalidade (auth, enderecos, home, carrinho, pedidos, loja, produto, splash). Cada módulo segue o padrão: bloc/ (Cubit + State), models/ (modelos com Equatable e copyWith), repositories/ (abstração que chama services), services/ (chamadas HTTP com ApiClient), views/ (telas), widgets/ (componentes reutilizáveis). Exemplo: módulo enderecos tem EnderecoCubit, EnderecoState (EnderecoInitial, EnderecoLoading, EnderecoLoaded, EnderecoError, EnderecoOperacaoSucesso, EnderecoCepBuscando, EnderecoCepCarregado), EnderecoModel (com getters resumido, enderecoCompleto, enderecoResumido e parse robusto de principal e numero), EnderecoRepository, EnderecoService, EnderecosListView, EnderecoFormView, EnderecoEditView, EnderecoActionCards.

Cubits gerenciam estado local e chamam repository -> service -> API. Exemplo de fluxo: View chama context.read<MeuCubit>().metodo(), Cubit emite Loading, processa, emite Loaded ou Error, View reage com BlocBuilder/BlocConsumer.

Injeção de dependências centralizada em app/di/dependencies.dart com GetIt. ApiClient é singleton, Cubits são factories. Exemplo: getIt.registerLazySingleton<ApiClient>(() => ApiClient()); getIt.registerFactory<EnderecoCubit>(() => EnderecoCubit(getIt<EnderecoRepository>())); Nas views, Cubit é acessado via context.read ou BlocProvider.

Backend: autenticação por device_id (header X-Device-Id ou body). Ao criar primeiro endereço, retorna token e usuario; AuthCubit.onEnderecoCriadoComToken persiste. Endpoints: GET /addresses (lista), POST /addresses (cria), PUT /addresses/{id} (atualiza), DELETE /addresses/{id} (soft delete), PUT /addresses/{id}/set-padrao (define principal), POST /addresses/buscar-cep (busca ViaCEP). O controller PHP correspondente é EnderecoController com actions index, view, create, update, delete, setPadrao, buscarCep. O formatEndereco retorna campos como principal, numero, logradouro, bairro, cidade, uf, cep, complemento, referencia, etc.

Rotas do app: splash (/), onboarding, home, meusEnderecos, enderecoForm, enderecoEdit, carrinho, pedidos, perfil, etc. Definidas em app/routes/app_routes.dart.

Fluxos principais: onboarding (Splash -> Onboarding busca CEP -> completar cadastro nome/email -> criar endereço opcional). Gerenciamento de endereços: listagem com destaque visual (borda laranja e selo Principal) para endereço principal. Toque no card define principal (cubit.definirPrincipal). Ícone lápis edita apenas número, complemento e referência (EnderecoEditView). Ícone lixeira exclui com confirmação (cubit.deletarEndereco). FAB adiciona novo endereço (EnderecoFormView). Home: LocalizacaoCubit gerencia endereço atual e lojas próximas.

Convenções: textos em pt-BR, cores via context.primaryColor, context.surfaceColor, context.textPrimary, tipografia com AppTextStyles, telas usam ResponsivePageScaffold, modelos têm Equatable e copyWith, navegação com settings.arguments.

Pontos de atenção: Não alterar EnderecoModel, EnderecoCubit ou EnderecoState sem revisar views. Cubit já tem cache local e flag _operacaoConcluida contra duplicidade. Edição de endereço restrita a número, complemento e referência. Nova rota deve ser registrada em app_routes.dart e no MaterialApp. Backend retorna principal (bool) e numero (string) – parse já é robusto.
