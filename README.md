## Atmus ☀️🌧️  
Aplicativo Flutter para previsão do tempo com interface intuitiva, recursos avançados e uso offline. Inspirado nos apps Weather.com e AccuWeather, com foco em simplicidade, clareza e utilidade prática.

---

## 📱 Descrição do Projeto

O **Atmus** é um aplicativo móvel que fornece previsões meteorológicas precisas e detalhadas, facilitando o planejamento de atividades diárias e semanais. Desenvolvido com **Flutter**, o app consome dados da API **WeatherAPI**, oferecendo uma experiência fluida e visualmente agradável para usuários de diferentes perfis.

---

## 🎯 Objetivo

Prover um aplicativo simples, confiável e rápido que permita:
- Consultar as condições climáticas atuais
- Visualizar previsões horárias e para os próximos dias
- Acessar dados detalhados como umidade, pressão, vento e índice UV
- Receber alertas climáticos
- Utilizar o app offline com base na última consulta salva

---

## 👤 Público-Alvo

Pessoas de todas as idades que desejam praticidade na consulta do clima, incluindo:
- Usuários em movimento com pouco tempo disponível
- Pessoas com baixa familiaridade com tecnologia
- Usuários exigentes que buscam detalhes climáticos

---

## 📱 Funcionalidades

- 🔍 Busca por cidade
- 🌡️ Condições climáticas atuais
- 🕒 Previsão por hora
- 📆 Previsão para os próximos 5 dias
- 📊 Visualização de dados detalhados (umidade, UV, vento, pressão)
- 🌆 Favoritar cidades para consulta rápida
- 🌥️ Condições do céu (nublado, ensolarado etc.)
- 🎯 Sensação térmica
- 📶 Uso offline com cache da última consulta
- 🗺️ Mapa interativo com previsão de nuvens e temperatura
- ⚠️ Alertas meteorológicos
- 🌙 Modo claro/escuro

---

## 📐 Protótipo

Protótipo de alta fidelidade criado no Figma, com as principais telas e fluxos:

🔗 [Acessar protótipo no Figma](https://www.figma.com/design/HH56kSxq715hcZZr0FD8Zu/ATMUS?node-id=0-1&p=f&t=QttI6aIBM7m235yk-0)

### Telas Principais
- Tela Inicial (Splash)
- Tela Principal (Home)
- Previsão Estendida
- Dados Climáticos Detalhados
- Mapa Interativo
- Lista de Cidades Favoritas
- Configurações

---

## 🚀 Tecnologias Utilizadas

- **Linguagem:** Dart
- **Framework:** Flutter
- **APIs:** [WeatherAPI](https://www.weatherapi.com/)
- **Persistência local:** Hive ou SharedPreferences
- **Gerenciamento de estado:** Provider
- **Protótipos:** Figma
- **Versionamento:** Git + GitHub

---

## 🗂️ Estrutura do Projeto

```
lib/
├── main.dart
├── secrets.dart         # chave da API
├── models/              # modelagem dos dados da API
├── services/            # integração com WeatherAPI
├── ui/
│   ├── screens/         # telas principais
│   └── widgets/         # componentes reutilizáveis
└── utils/               # helpers e conversões
```

---

## 📋 Histórias de Usuário / Backlog

Alguns exemplos:

- `US001`: Como usuário, desejo visualizar as condições climáticas atuais da minha cidade para me preparar ao sair de casa.
- `US005`: Como usuário, desejo ver detalhes como umidade, sensação térmica e índice UV para entender melhor o clima.
- `US009`: Como usuário frequente, desejo salvar cidades favoritas para acesso rápido.

✅ Lista completa das histórias de usuário e Backlog no [GitHub Projects](https://github.com/orgs/AtmusDAM/projects/1)

---

## 🧪 Validação com Usuários

Testes de usabilidade foram realizados com 3 usuários com perfis distintos:
- Ultramaratonista (54 anos): dificuldades na leitura dos dados detalhados
- Advogado (26 anos): experiência fluida; achou a tela de mapa pouco útil
- Aposentada (79 anos): insegurança inicial, mas valorizou a clareza da previsão

🔍 *Resultado*: ajustes serão realizados nas explicações dos dados e na interface da tela de mapa.

---

## 📆 Planejamento de Sprints

| Sprint | Período       | Entregas                                               |
|--------|---------------|--------------------------------------------------------|
| 1      | 12/06 a 22/07   | Configuração inicial do projeto Flutter. Escolha da API(WeatherAPI). Desenvolvimento do protótipo de alta fidelidade. Estruturação da documentação, criação da organização, repositório e project no Github            |
| 2      | 23/07 a 04/08  | Desenvolvimento da tela inicial e tela principal como exibição de dados climáticos atuais, integração com WeatherAPI. Implementação da busca por cidade, desenvolvimento da tela de busca estendida e dados detalhados. Implementação da navegação principal entre as telas.           |
| 3      | 05/08 a 16/08  | Desenvolvimento da Tela de Mapa Interativo. Implementação das funcionalidades de favoritos e Tela de Lista de Locais. Desenvolvimento da Tela de Configurações e Modo Noturno. Inclusão de tooltips ou textos explicativos para dados detalhados (melhoria).            |
| 4      | 17/08 a 27/08   | Implementação de mensagens de alerta de chuva. Refinamento do uso offline. Implementação do cache para a última cidade consultada. Refinamentos e testes de todas as funcionalidades implementadas       |

---

## 💡 Diferenciais

- Interface responsiva e adaptada para idosos e usuários com baixa familiaridade
- Uso offline mesmo sem conexão
- Alertas meteorológicos integrados
- Modo escuro configurável

---

## 🛠️ Instalação e Execução

1. Clone o repositório:
   ```bash
   git clone https://github.com/AtmusDAM/Atmus.git
   cd Atmus
   ```

2. Instale as dependências:
   ```bash
   flutter pub get
   ```

3. Execute o projeto:
   ```bash
   flutter run
   ```

---

## 🔑 Como obter a chave da API (caso queira)

1. Acesse [https://www.weatherapi.com/](https://www.weatherapi.com/)
2. Crie uma conta gratuita
3. Copie sua chave de API (`YOUR_API_KEY`)
4. Crie um arquivo `.env` ou configure como variável local dentro do projeto (`lib/secrets.dart`):

```dart
// lib/secrets.dart
const String weatherApiKey = 'YOUR_API_KEY';
```

> **Importante**: Não exponha sua chave em repositórios públicos!

---

## 🔌 Exemplos de chamadas à API

### Clima atual:
```
GET https://api.weatherapi.com/v1/current.json?key=YOUR_API_KEY&q=Garanhuns&lang=pt
```

### Previsão estendida (até 10 dias):
```
GET https://api.weatherapi.com/v1/forecast.json?key=YOUR_API_KEY&q=Garanhuns&days=5&lang=pt
```

---

## 📌 Melhorias Futuras

- 🌎 Geolocalização automática
- 🧠 Cache de cidades consultadas
- 📊 Gráficos de temperatura e precipitação
- 🔔 Notificações meteorológicas

---
## 📋 Documentação

✅Documentação oficial do Projeto [Link](https://drive.google.com/file/d/17npe3p7KAZWHGr4ZlKNvmhfKgQFHU4FK/view?usp=sharing)

---

## 🤝 Desenvolvedores

- Joás
- Tayane
- Leonardo

---

## 📄 Licença

Este projeto é acadêmico, sem fins lucrativos, e segue os princípios de uso justo de APIs para fins educacionais.

---
