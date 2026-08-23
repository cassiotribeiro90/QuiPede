# 🍔 QuiPede - Delivery Ecosystem

O **QuiPede** é a ponta de lança do ecossistema **QuiDelivery**, focado na experiência de compra do cliente final. Este aplicativo não é apenas uma interface de pedidos, mas um sistema robusto que integra geolocalização, inteligência de cardápio e autenticação segura em um ambiente multiplataforma (Android, iOS, Windows e Web).

![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.2+-0175C2?style=flat-square&logo=dart&logoColor=white)
![BLoC](https://img.shields.io/badge/BLoC-8.1+-29B6F6?style=flat-square&logo=bloc&logoColor=white)
![Architecture](https://img.shields.io/badge/Arch-Modular--Layered-orange?style=flat-square)

---

## 📸 Interface do Usuário

<img width="200" alt="image" src="https://github.com/user-attachments/assets/dc50c219-93f6-4efd-962e-ab7ed3e238dd" /> 
<img width="200" alt="image" src="https://github.com/user-attachments/assets/c97329fb-0a5c-4cb2-a332-43737ddfcb6d" />
<img width="200"alt="image" src="https://github.com/user-attachments/assets/6623cf14-1966-4422-9384-6defb974e57a" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/d8a4e19e-d595-46ea-9b02-f7515d00f898" />
<img width="200" alt="image" src="https://github.com/user-attachments/assets/d280096b-bd9e-43ae-be49-88a2698c3843" />


---

## 🚀 Funcionalidades Detalhadas

### 📍 Inteligência Geográfica
- **Busca por CEP/Endereço**: Integração com APIs de geocodificação para localizar o usuário.
- **Raio de Atendimento**: Filtro dinâmico que exibe apenas lojas que entregam na localização atual.
- **Cálculo de Distância**: Exibição da proximidade real entre o cliente e o estabelecimento.

### 📋 Cardápio de Alta Performance
- **Sticky Headers**: Menu de categorias que permanece fixo no topo durante a rolagem.
- **Scroll Inteligente**: Ao clicar em uma categoria, o app carrega os dados necessários da API e rola com precisão até a seção desejada.
- **Customização de Itens**: Suporte completo a complementos (ex: bordas de pizza, tamanhos de bebidas) e observações por item.

### 🔐 Segurança e Autenticação
- **Flow OTP (One-Time Password)**: Login rápido via número de telefone com verificação por código.
- **Sessão Convidado**: Permite ao usuário navegar e montar o carrinho antes de exigir a criação de conta.
- **Device ID Unificado**: Identificação única do dispositivo para controle de notificações e segurança transacional.

---

## 🏗️ Arquitetura e Padrões

O projeto utiliza uma arquitetura **Modular e Camada**, garantindo que cada funcionalidade seja independente e fácil de testar.

### Estrutura de Pastas
```text
lib/
├── app/
│   ├── core/           # Temas, Services globais e Constants
│   ├── di/             # Configuração do GetIt (Injeção de Dependência)
│   ├── models/         # Modelos de dados globais
│   ├── modules/        # Funcionalidades isoladas (auth, home, lojas, etc)
│   │   └── module_name/
│   │       ├── bloc/   # Lógica de negócio (Cubit/BLoC)
│   │       ├── views/  # Widgets de tela
│   │       └── widgets/# Componentes locais
│   └── routes/         # Gestão de rotas nomeadas
└── shared/             # Componentes, API Clients e Utils reutilizáveis
```

### Tecnologias "Under the Hood"
- **Gerenciamento de Estado**: `Cubit` para fluxos simples e previsíveis.
- **Rede**: `Dio` com interceptores para injeção automática de Tokens e Device IDs em todos os headers.
- **Injeção de Dependência**: `GetIt` para desacoplar as camadas de serviço da UI.
- **Notificações**: `Firebase Cloud Messaging (FCM)` configurado para inicialização diferida na Web (evitando bloqueios de UI).

---

## 🖥️ Nuances Multiplataforma

O QuiPede foi otimizado para rodar com excelência em diferentes ambientes:

- **Windows Desktop**: 
    - Implementação de `AppScrollBehavior` para permitir rolagem por arrasto de mouse (padrão mobile).
    - Configurações de CMake para garantir compilação correta de plugins nativos como `flutter_tts` e Firebase.
- **Web**:
    - Gestão de permissões de notificação assíncronas para evitar a "tela branca" inicial.
    - Otimização de renderização para diferentes resoluções.
- **Mobile (Android/iOS)**:
    - Uso intensivo de hardware nativo para localização e sensores.

---

## 📘 O Ecossistema QuiDelivery

O QuiPede é um dos três pilares da nossa solução de delivery:

1. **QuiPede (Client)**: Onde o pedido nasce.
2. **[QuiManda](https://github.com/seu-usuario/quimanda) (Merchant)**: Onde o lojista gerencia o fluxo de produção e cardápio.
3. **[QuiGestor](https://github.com/seu-usuario/quigestor) (Admin)**: A torre de controle para administração global da plataforma.

**Backend**: API desenvolvida em **Yii2 (PHP)** com banco **MySQL**, projetada para baixa latência e alta disponibilidade.

---

## 🛠️ Como Rodar

### 1. Configurar o Backend
Este projeto depende da API do ecossistema QuiDelivery.
- Acesse o repositório do backend (Yii2).
- Utilize os arquivos **Docker** inclusos para subir os containers do PHP, MySQL e Nginx.
- Certifique-se de que a API está acessível no endereço configurado em `lib/app_config.dart`.

### 2. Configurar o Firebase
- Crie um projeto no [Console do Firebase](https://console.firebase.google.com/).
- Adicione aplicativos Android, iOS e Web ao projeto.
- Baixe os arquivos de configuração (`google-services.json`, `GoogleService-Info.plist`).
- Configure o arquivo `lib/firebase_options.dart` com as chaves geradas para habilitar o FCM e outras funcionalidades.

### 3. Executar o Aplicativo
- Certifique-se de ter o **Flutter 3.16+** instalado.
- Instale as dependências:
  ```bash
  flutter pub get
  ```
- Rode o projeto na plataforma desejada:
  ```bash
  flutter run -d windows # Para Windows Desktop
  flutter run -d chrome  # Para Web
  flutter run            # Para Android/iOS
  ```

---
Desenvolvido com ❤️ por **Cássio** | 2026
