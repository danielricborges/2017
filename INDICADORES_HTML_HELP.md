# Gerador de Indicadores HTML - Manual de Uso

## Visão Geral
A tela `w_indicadores_html_generator` permite gerar relatórios HTML de indicadores RECOF através da execução das funções da package Oracle `PKG_INDICADORES`.

## Como Usar

### 1. Abrir a Tela
No PowerBuilder, abra a janela `w_indicadores_html_generator`.

### 2. Selecionar a Função
No dropdown "Função Geradora", selecione o indicador desejado:
- **Quantidade Fracionada**: Indicador de quantidades fracionadas
- **DUE Averbada**: Indicador de DUE averbada
- **RECOF sem Contabilidade**: Indicador de RECOF sem contabilidade
- **RECOF Retificações**: Indicador de retificações RECOF
- **Troca de NCM**: Indicador de trocas de NCM
- **DI Vencida Antes da DUE**: DIs RECOF com vencimento antes da averbação da DUE
- **CFOP Importação**: Divergência de CFOP na Admissão RECOF
- **RECOF Intermediário**: Impostos em NF de Venda RECOF Intermediário
- **Saldo Vencido**: Saldo Vencido em Estoque RECOF

### 3. Informar os Parâmetros

#### Parâmetros Obrigatórios:
- **Período Inicial**: Data inicial no formato `YYYYMM` (ex: `202401` para Janeiro/2024)
- **Período Final**: Data final no formato `YYYYMM` (ex: `202412` para Dezembro/2024)
- **Top Empresas**: Quantidade de empresas a exibir no ranking (padrão: 10)

#### Parâmetros Opcionais:
- **CNPJ Raiz**: Filtrar por CNPJ específico (deixe vazio ou `%` para todas as empresas)
  - Exemplo: `12345678` para filtrar apenas empresas com esse CNPJ raiz
  - **Nota**: Este campo é desabilitado para "RECOF Retificações"

- **Top Pares NCM**: Quantidade de pares de NCM a exibir (apenas para "Troca de NCM")

### 4. Gerar o Relatório
1. Clique no botão **"Gerar Relatório"**
2. Aguarde o processamento (cursor de ampulheta será exibido)
3. O relatório HTML será:
   - Salvo em arquivo temporário (formato: `indicador_YYYYMMDD_HHMMSS.html`)
   - Aberto automaticamente no navegador padrão
4. Uma mensagem de sucesso será exibida

### 5. Fechar a Tela
Clique no botão **"Fechar"** ou feche a janela normalmente.
O arquivo temporário será excluído automaticamente.

## Exemplos de Uso

### Exemplo 1: Gerar relatório de Quantidade Fracionada
- **Função**: Quantidade Fracionada
- **Período Inicial**: 202401
- **Período Final**: 202403
- **CNPJ Raiz**: % (todas as empresas)
- **Top Empresas**: 15

### Exemplo 2: Gerar relatório de Troca de NCM para empresa específica
- **Função**: Troca de NCM
- **Período Inicial**: 202301
- **Período Final**: 202312
- **CNPJ Raiz**: 12345678
- **Top Empresas**: 10
- **Top Pares NCM**: 20

### Exemplo 3: Gerar relatório de RECOF Retificações
- **Função**: RECOF Retificações
- **Período Inicial**: 202401
- **Período Final**: 202406
- **CNPJ Raiz**: (desabilitado - não usado nesta função)
- **Top Empresas**: 15

## Formato dos Períodos
Os períodos devem ser informados no formato `YYYYMM`:
- **YYYY**: Ano com 4 dígitos (ex: 2024)
- **MM**: Mês com 2 dígitos (01 a 12)

Exemplos válidos:
- `202401`: Janeiro de 2024
- `202312`: Dezembro de 2023
- `202406`: Junho de 2024

## Observações Importantes

1. **Conexão com Banco de Dados**: Certifique-se de estar conectado ao banco de dados Oracle antes de gerar os relatórios

2. **Package Oracle**: A package `PKG_INDICADORES` deve estar instalada e acessível no banco de dados

3. **Permissões**: O usuário deve ter permissão de execução nas funções da package

4. **Arquivo Temporário**: O arquivo HTML é salvo no diretório temporário do Windows e é excluído ao fechar a tela

5. **Navegador**: O relatório será aberto no navegador padrão configurado no Windows

## Mensagens de Erro Comuns

- **"Por favor, selecione uma função geradora de indicador"**: Selecione uma função no dropdown
- **"Por favor, informe o período inicial"**: Preencha o campo de período inicial
- **"Top empresas deve ser um número inteiro"**: Informe apenas números no campo Top Empresas
- **"Erro ao preparar a chamada da procedure"**: Verifique a conexão com o banco de dados
- **"A consulta não retornou nenhum dado"**: Não há dados para o período/filtros informados

## Funções da Package PKG_INDICADORES

### Assinaturas das Funções:

```sql
-- Quantidade Fracionada
FUNCTION gerar_html_qtd_fracionada (
  p_periodo_ini        IN VARCHAR2,
  p_periodo_fim        IN VARCHAR2,
  p_cnpj_raiz_opcional IN VARCHAR2 DEFAULT '%',
  p_top_empresas       IN PLS_INTEGER DEFAULT 10
) RETURN CLOB;

-- DUE Averbada
FUNCTION gerar_html_due_averbada (
  p_periodo_ini        IN VARCHAR2,
  p_periodo_fim        IN VARCHAR2,
  p_cnpj_raiz_opcional IN VARCHAR2 DEFAULT '%',
  p_top_empresas       IN PLS_INTEGER DEFAULT 8
) RETURN CLOB;

-- RECOF sem Contabilidade
FUNCTION gerar_html_recof_sem_contab (
  p_periodo_ini        IN VARCHAR2,
  p_periodo_fim        IN VARCHAR2,
  p_cnpj_raiz_opcional IN VARCHAR2 DEFAULT '%',
  p_top_empresas       IN PLS_INTEGER DEFAULT 15
) RETURN CLOB;

-- RECOF Retificações
FUNCTION gerar_html_recof_retificacoes (
  p_periodo_ini  IN VARCHAR2,
  p_periodo_fim  IN VARCHAR2,
  p_top_empresas IN PLS_INTEGER DEFAULT 15
) RETURN CLOB;

-- Troca de NCM
FUNCTION gerar_html_troca_ncm (
  p_periodo_ini        IN VARCHAR2,
  p_periodo_fim        IN VARCHAR2,
  p_cnpj_raiz_opcional IN VARCHAR2 DEFAULT '%',
  p_top_empresas       IN PLS_INTEGER DEFAULT 10,
  p_top_pares          IN PLS_INTEGER DEFAULT 10
) RETURN CLOB;

-- DI Vencida Antes da DUE
FUNCTION gerar_html_di_vencida_antes_due (
  p_periodo_ini        IN VARCHAR2,
  p_periodo_fim        IN VARCHAR2,
  p_cnpj_raiz_opcional IN VARCHAR2 DEFAULT '%',
  p_top_empresas       IN PLS_INTEGER DEFAULT 10
) RETURN CLOB;

-- CFOP Importação
FUNCTION gerar_html_cfop_importacao (
  p_periodo_ini        IN VARCHAR2,
  p_periodo_fim        IN VARCHAR2,
  p_cnpj_raiz_opcional IN VARCHAR2 DEFAULT '%',
  p_top_empresas       IN PLS_INTEGER DEFAULT 10
) RETURN CLOB;

-- RECOF Intermediário
FUNCTION gerar_html_recof_intermediario (
  p_periodo_ini        IN VARCHAR2,
  p_periodo_fim        IN VARCHAR2,
  p_cnpj_raiz_opcional IN VARCHAR2 DEFAULT '%',
  p_top_empresas       IN PLS_INTEGER DEFAULT 5
) RETURN CLOB;

-- Saldo Vencido
FUNCTION gerar_html_saldo_vencido (
  p_periodo_ini        IN VARCHAR2,
  p_periodo_fim        IN VARCHAR2,
  p_cnpj_raiz_opcional IN VARCHAR2 DEFAULT '%',
  p_top_empresas       IN PLS_INTEGER DEFAULT 15
) RETURN CLOB;
```

## Suporte Técnico
Para dúvidas ou problemas, consulte a equipe de desenvolvimento.
