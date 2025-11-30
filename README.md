# Service App (Cadastro de Serviços)

Aplicativo Flutter simples para cadastrar ordens de serviço com os campos solicitados:

- `id` (autoincrement)
- `date` (ex: 27/11/2025)
- `clientName` (ex: JOAO DA SILVA)
- `deviceName` (ex: TV LG 52)
- `serialNumber` (ex: 00205561EF45)
- `reason` (ex: NÃO LIGA)
- `servicePerformed` (ex: TROCA DA PLACA LOGICA)
- `value` (ex: 300.00)
- `status` (string: `pending` | `finalized` | `cancelled`)

O app usa `sqflite` para armazenamento local e tem listagem dos serviços cadastrados. Internamente foi adicionada uma coluna `status` (texto) para permitir os estados `Pendente`/`Finalizado`/`Cancelado` — versões antigas que usavam o campo booleano `finalized` são migradas automaticamente.

Como usar

1. Instale o Flutter SDK: https://flutter.dev/docs/get-started/install
2. No PowerShell, navegue para a pasta do projeto:

```powershell
cd "C:\Users\Sheila\Documents\trabalhoSubstitutiva\service_app"
```

3. Baixe dependências:

```powershell
flutter pub get
```

4. Rode no emulador ou dispositivo conectando um aparelho:

```powershell
flutter run
```

**Observações**

- **Arquivos principais:**
  - `lib/main.dart` — inicialização
  - `lib/models/service.dart` — modelo de dados (agora com `status`)
  - `lib/db/db_helper.dart` — acesso ao SQLite e migração para coluna `status`
  - `lib/pages/home_page.dart` — listagem, filtros, exportação e ações sobre cada registro (exibe status colorido)
  - `lib/pages/add_service_page.dart` — formulário de cadastro/edição (agora permite escolher `Pendente|Finalizado|Cancelado`)
  - `lib/utils/csv_exporter.dart` — utilitário para exportar CSV (agora inclui coluna `status`)

**Novas funcionalidades e mudanças importantes**

- **Campo `status`:** substitui o uso exclusivo do booleano `finalized`. Valores possíveis: `pending`, `finalized`, `cancelled`. Aplicações antigas que tinham `finalized` serão migradas automaticamente na primeira execução.
- **Formulário:** o formulário de cadastro/edição (`Add Service`) possui um `Dropdown` para escolher o `status` explicitamente.
- **Listagem:** cada item mostra o status com cor: verde = Finalizado, amarelo = Pendente, vermelho = Cancelado. Itens marcados como `Cancelado` não mostram o checkbox de finalização (aparecem apenas com o texto vermelho).
- **CSV:** o exportador adiciona a coluna `status` ao CSV (mantendo também a coluna legada `finalized` como 0/1 para compatibilidade).
- **Migração de banco:** o app atualiza o esquema do banco para incluir `status` (versão do DB incrementada). Há lógica para manter compatibilidade com bases antigas.
- **Android NDK:** Para builds Android, foi fixado `ndkVersion = "27.0.12077973"` em `android/app/build.gradle.kts` para compatibilidade com alguns plugins (`path_provider_android`, `sqflite_android`). Se ocorrer erro relacionado ao NDK, adicione/ajuste essa propriedade.

Se quiser que eu adicione mais recursos (ex.: ordenação por data, exportar para local externo, sincronização com servidor ou geração de APK), responda com o que prefere.
