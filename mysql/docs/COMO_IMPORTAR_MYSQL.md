# Como importar o banco MySQL

Este guia recria o schema relacional `recursos_hidricos` a partir do export versionado em `mysql/exports/recursos_hidricos_schema.sql`. O arquivo contém somente a estrutura: não há registros, credenciais, contas de servidor ou caminhos locais.

## Pré-requisitos

- MySQL Server 8.0 compatível, instalado e em execução.
- MySQL Workbench para o procedimento gráfico.
- Git.
- Um usuário local do MySQL com permissão para criar schemas e tabelas.

O MySQL Workbench é uma ferramenta de gerenciamento. Ele não substitui o MySQL Server: o serviço do servidor precisa estar instalado, iniciado e acessível antes da importação.

## Obter o projeto

```bash
git clone https://github.com/GiovanniADCS/bd2-Water-Management.git
cd bd2-Water-Management
git switch feat/mysql-initial-schema
```

## Importar pelo MySQL Workbench

1. Abra o MySQL Workbench.
2. Conecte-se ao MySQL Server local.
3. Selecione **File > Open SQL Script**.
4. Abra `mysql/exports/recursos_hidricos_schema.sql` dentro do repositório clonado.
5. Execute o script completo pelo ícone de raio ou por **Query > Execute (All or Selection)**.
6. No painel **Schemas**, clique em **Refresh All**.
7. Confirme a existência do schema `recursos_hidricos`.
8. Expanda **Tables** e confirme as 30 tabelas.
9. Abra e execute `mysql/verification/002_verify_schema.sql`.

Na primeira consulta do script de verificação, o resultado esperado é:

- 30 tabelas;
- 30 chaves primárias;
- 48 chaves estrangeiras;
- 15 restrições `UNIQUE` adicionais às chaves primárias;
- nenhuma divergência na lista de tabelas;
- nenhuma linha nas tabelas.

As consultas seguintes detalham engine, collation, colunas, constraints e índices. As consultas de divergência não devem retornar linhas.

## Importar pela linha de comando no Windows

Abra o Prompt de Comando ou o PowerShell na raiz do repositório. O executável `mysql` precisa estar disponível no `PATH`. Use somente a opção `--password`, sem colocar a senha no comando; o cliente solicitará a senha de forma interativa.

No Prompt de Comando (`cmd.exe`):

```bat
mysql --host=localhost --port=3306 --user=SEU_USUARIO --password < mysql\exports\recursos_hidricos_schema.sql
mysql --host=localhost --port=3306 --user=SEU_USUARIO --password < mysql\verification\002_verify_schema.sql
```

No PowerShell:

```powershell
mysql --host=localhost --port=3306 --user=SEU_USUARIO --password --execute="SOURCE mysql/exports/recursos_hidricos_schema.sql"
mysql --host=localhost --port=3306 --user=SEU_USUARIO --password --execute="SOURCE mysql/verification/002_verify_schema.sql"
```

Substitua `SEU_USUARIO` pelo usuário local do MySQL. Não grave senhas no terminal, em scripts ou em arquivos versionados.

## Observações e solução de problemas

- O export foi gerado no MySQL 8.0.46 com `--no-data`, sem triggers, sem `DROP TABLE` e com GTID desabilitado no dump.
- O script cria o schema com `utf8mb4` e `utf8mb4_0900_ai_ci` e recria as tabelas InnoDB, chaves e índices.
- A importação é destinada a um ambiente novo. Como as tabelas são criadas sem `IF NOT EXISTS`, não execute novamente o arquivo sobre uma instalação já criada sem revisar o estado do banco.
- Se a conexão falhar, confirme que o serviço MySQL Server está em execução; abrir apenas o Workbench não inicia necessariamente o servidor.
- Se aparecer erro de permissão, use uma conta autorizada a executar `CREATE DATABASE` e `CREATE TABLE`.
- Se o schema não aparecer após a execução, atualize o painel **Schemas**.
- A população planejada de 50.000 registros não faz parte desta etapa e será executada posteriormente.
