## 📱 Service App — Cadastro de Ordens de Serviço
Aplicação Flutter desenvolvida para gerenciamento completo de ordens de serviço, com persistência local via SQLite, filtros avançados, controle de status e exportação de dados.
Ideal para uso interno em assistências técnicas, suporte, manutenção e prestação de serviços.
## 🚀 Funcionalidades Principais

### ✔️ CRUD Completo

Criar, visualizar, atualizar e excluir ordens de serviço.

### ✔️ Controle de Status

Sistema visual intuitivo:

🟡 Pendente — Estado inicial.

🟢 Finalizado — Serviço concluído.

🔴 Cancelado — Mantido no histórico, sem possibilidade de finalizar.

### ✔️ Banco de Dados Local (SQLite)

Persistência offline usando sqflite.

Sistema de migração automática da estrutura legada (coluna finalized) para o novo campo status.

### ✔️ Busca Avançada (SearchDelegate)

Pesquisa por:

Nome do Cliente

Nome do Aparelho

Número de Série

Serviço Realizado

ID da OS

### ✔️ Filtros e Ordenação

Filtrar por status: Todos | Finalizados | Pendentes

Ordenar por data: Mais Recentes | Mais Antigas

### ✔️ Exportação para CSV

Exporta toda a base local para um arquivo .csv

Arquivo salvo no diretório de documentos do dispositivo

### ✔️ Interface Moderna

Design limpo usando Google Fonts (Inter)

Ações intuitivas como deslizar para excluir (Dismissible)
## 🛠️ Tecnologias Utilizadas
Tecnologia / Biblioteca	Uso
Flutter & Dart	Base do aplicativo
sqflite	Banco de dados SQLite local
path_provider	Acesso ao sistema de arquivos
intl	Formatação de datas
google_fonts	Fonte Inter utilizada no UI
## 🗂️ Estrutura da Tabela (services)
Campo	Tipo	Descrição
id	INTEGER	Chave primária (autoincremento)
date	TEXT	Data de entrada (dd/MM/yyyy)
clientName	TEXT	Nome do cliente
deviceName	TEXT	Modelo do aparelho
serialNumber	TEXT	Número de série
reason	TEXT	Motivo/defeito relatado
servicePerformed	TEXT	Serviço executado
value	REAL	Valor do serviço
status	TEXT	pending, finalized, cancelled
🔄 Migração Automática

Caso o banco seja detectado na versão 1, contendo o campo finalized, ele é automaticamente convertido para o novo campo status.

## 📦 Instalação e Execução

### ✔️ Pré-requisitos

Flutter SDK configurado

Emulador ou dispositivo físico conectado

## 🔧 Clonar o projeto

```bash
git clone https://github.com/Sheila724/trabalhoLddm.git
cd trabalhoLddm
```
## 📦 Instalar dependências
```bash
flutter pub get
```

## ▶️ Executar
```bash
flutter run
```
## ⚠️ Configuração Específica do Android

O projeto define manualmente a versão do NDK no arquivo:

android/app/build.gradle.kts


Versão usada:

ndkVersion = "27.0.12077973"


Caso apareça erro referente ao NDK, instale esta versão pelo
Android Studio → SDK Manager → SDK Tools → NDK (Side by side).

📂 Estrutura do Projeto
lib/
├── main.dart               # Ponto de entrada
├── models/                 # Models (ORM)
├── db/                     # Singleton + scripts de migração
├── pages/                  # Telas (Lista e Formulário)
└── utils/                  # Exportação CSV e utilitários

💙 Desenvolvido com Flutter

Projeto acadêmico desenvolvido com foco em boas práticas, organização de código e robustez no gerenciamento de dados locais.