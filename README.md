# 🏗️ Pipeline Lakehouse End-to-End

![Status](https://img.shields.io/badge/status-concluído-brightgreen?style=flat-square)
![Python](https://img.shields.io/badge/Python-3.11-blue?style=flat-square&logo=python)
![PySpark](https://img.shields.io/badge/PySpark-3.5-orange?style=flat-square&logo=apachespark)
![Databricks](https://img.shields.io/badge/Databricks-Free%20Edition-red?style=flat-square&logo=databricks)
![Delta Lake](https://img.shields.io/badge/Delta%20Lake-Medallion-00ADD8?style=flat-square)
![dbt](https://img.shields.io/badge/dbt-Core-FF694B?style=flat-square&logo=dbt)
![Unity Catalog](https://img.shields.io/badge/Unity%20Catalog-Databricks-red?style=flat-square&logo=databricks)
![Workflows](https://img.shields.io/badge/Databricks-Workflows-red?style=flat-square&logo=databricks)

> Pipeline de dados completo com arquitetura Medallion (Bronze / Silver / Gold),
> processamento distribuído com PySpark, modelagem analítica com dbt Core,
> orquestração com Databricks Workflows e dashboard nativo —
> 100% na plataforma Databricks Free Edition, sem custo de infraestrutura externa.

---

## 🚦 Status do Projeto

| Camada | Status | Entregável |
|--------|--------|------------|
| Bronze | ✅ Concluída | Ingestão paginada da API + Volume particionado por data |
| Silver | ✅ Concluída | PySpark + Delta Lake particionado por state + country |
| Gold | ✅ Concluída | dbt Core + 3 modelos analíticos no SQL Warehouse |
| Orquestração | ✅ Concluída | Databricks Workflows multi-task (schedule diário 06h) |
| Dashboard | ✅ Concluído | 4 widgets · 8.180 cervejarias · 51 estados · dados validados |

---

## 📋 Sobre o Projeto

Este projeto foi construído como **projeto âncora de portfólio** durante minha transição estruturada de Suporte Técnico para Engenharia de Dados.

O objetivo é replicar uma arquitetura Lakehouse moderna cobrindo todo o ciclo: **ingestão → transformação → modelagem → orquestração → consumo**.

**Fonte de dados:** [Open Brewery DB API](https://www.openbrewerydb.org/) — API pública REST com dados de ~9.459 cervejarias (localização, tipo, website, contato).

**Decisão de arquitetura:** todo o projeto roda 100% no Databricks Free Edition, utilizando Unity Catalog como metastore, Volumes para armazenamento Bronze, Delta Lake para Silver e Gold, e Databricks Workflows para orquestração — sem dependência de serviços externos como AWS S3 ou Apache Airflow.

---

## 🏛️ Arquitetura

```
Open Brewery DB API (~9.459 registros)
         │
         │  Python + requests (paginação completa)
         ▼
┌──────────────────────────────────────────────┐
│  BRONZE — Databricks Volume                  │
│  /Volumes/lakehouse_portfolio/bronze/        │
│  breweries_raw/year=YYYY/month=MM/day=DD/    │
│  data.json  ← JSON bruto, sem transformações │
└───────────────────┬──────────────────────────┘
                    │  PySpark
                    ▼
┌──────────────────────────────────────────────┐
│  SILVER — Delta Lake                         │
│  lakehouse_portfolio.silver.breweries        │
│  Particionado por state                      │
│  Limpo, tipado, deduplicado                  │
└───────────────────┬──────────────────────────┘
                    │  dbt Core
                    ▼
┌──────────────────────────────────────────────┐
│  GOLD — dbt models (SQL Warehouse)           │
│  stg_breweries (view)                        │
│  mart_by_state / mart_by_type (tables)       │
│  Filtrado por USA · Capitalização padronizada│
└──────────────┬───────────────────────────────┘
               │
               ▼
      Databricks Dashboard
      (4 widgets nativos)
```

**Orquestração:** Job `lakehouse_pipeline_daily` com tasks em sequência:
`bronze_ingestion >> silver_transformation >> gold_dbt`
Schedule diário às 06h (America/Sao_Paulo) — execução validada em 2m9s, status Succeeded.

---

## 🛠️ Stack Técnica

| Camada | Tecnologia | Função |
|--------|-----------|--------|
| Ingestão | Python 3.11 + Requests | Coleta da API com paginação completa |
| Storage Bronze | Databricks Volumes + Unity Catalog | Armazenamento raw particionado por data |
| Processamento | PySpark | Transformações distribuídas Silver |
| Plataforma | Databricks Free Edition | Execução, catálogo e orquestração |
| Formato | Delta Lake | Tabelas ACID Silver e Gold |
| Modelagem | dbt Core | Transformações SQL + lineage automático |
| Orquestração | Databricks Workflows | Pipeline multi-task com schedule diário |
| Visualização | Databricks Dashboard nativo | Consumo analítico final |
| Catálogo | Unity Catalog | Governança, lineage e discovery de dados |
| Versionamento | Git + GitHub | Controle de versão integrado via Git Folders |

---

## 📁 Estrutura do Repositório

```
lakehouse-pipeline/
│
├── README.md
├── .gitignore                           ← protege credenciais (profiles.yml)
│
├── notebooks/
│   ├── 00_setup_ambiente.ipynb          ← Unity Catalog: catalog, schemas, volume
│   ├── 00_setup_dbt.ipynb               ← Criação da estrutura dbt via Python
│   ├── 01_bronze_ingestion.ipynb        ← Ingestão da API + save no Volume ✅
│   ├── 02_silver_transformacao.ipynb    ← PySpark + Delta Lake ✅
│   └── 03_gold_dbt.ipynb               ← Execução dbt Core ✅
│
└── dbt_gold/
    ├── dbt_project.yml
    ├── profiles.yml.example
    └── models/
        ├── staging/
        │   ├── sources.yml
        │   └── stg_breweries.sql        ← INITCAP(state) · filtro de nulos
        └── marts/
            ├── mart_by_state.sql        ← Agregação por estado (USA only)
            └── mart_by_type.sql         ← Agregação por tipo
```

---

## 📊 Camadas de Dados

### 🥉 Bronze — Dados Brutos ✅
- **Formato:** JSON particionado por data de ingestão
- **Storage:** `/Volumes/lakehouse_portfolio/bronze/breweries_raw/year=YYYY/month=MM/day=DD/data.json`
- **Princípio:** sem transformações — fidelidade total à fonte
- **Volume:** ~9.459 registros por execução

### 🥈 Silver — Dados Limpos ✅
- **Formato:** Delta Lake particionado por `state`
- **Storage:** `lakehouse_portfolio.silver.breweries`
- **Transformações:** remoção de nulos, padronização de tipos, deduplicação por `id`
- **Colunas preservadas:** inclui `country` para filtragem downstream

### 🥇 Gold — Dados Analíticos ✅
- **Formato:** Delta Lake via dbt Core no SQL Warehouse
- **Modelos:**
  - `stg_breweries` (view) — staging com `INITCAP(state)` para padronização de capitalização
  - `mart_by_state` (table) — total, cidades, % com website · filtrado por `country = 'United States'`
  - `mart_by_type` (table) — distribuição por tipo de cervejaria
- **Decisões de qualidade:**
  - `INITCAP(state)` no staging corrige inconsistências como `MIssouri` → `Missouri`
  - Filtro `country = 'United States'` no mart evita distorção por registros internacionais
  - Correções feitas no staging garantem que todos os modelos downstream herdam os dados corretos

---

## 📈 Dashboard

Dashboard nativo Databricks com dados validados e corrigidos:

- 🔢 **Total de cervejarias:** 8.180 (filtrado por USA)
- 🗺️ **Estados cobertos:** 51 (50 estados + DC)
- 🌐 **% com website:** 86,3%
- 📊 **Top 10 estados:** California (919), Washington (498), Michigan (419)...
- 🍩 **Distribuição por tipo:** micro (53,66%), brewpub (28,01%)...
- 📋 **Cobertura digital:** Rhode Island e Hawaii com 100%

---

## 🔍 Decisões de Arquitetura

| Decisão | Alternativa descartada | Motivo |
|---------|----------------------|--------|
| PySpark na Silver | Pandas | Escalabilidade — funciona com 100x mais dados sem mudança de código |
| dbt na Gold | PySpark | SQL simples + lineage automático + documentação — menos código, mais valor |
| Staging como VIEW | TABLE | Não ocupa storage — é camada de passagem, não de destino |
| Marts como TABLE | VIEW | Leitura instantânea pelo dashboard sem recalcular agregações |
| Workflows nativo | Airflow | Pipeline 100% Databricks — sem infraestrutura extra |
| INITCAP no staging | Corrigir na fonte | Correção na camada certa — todos os modelos downstream herdam automaticamente |

---

## 🔐 Segurança

- `profiles.yml` nunca commitado — protegido via `.gitignore`
- Token com escopo restrito (`sql` apenas)
- Credenciais gerenciadas fora do repositório

---

## 🚀 Como Reproduzir

### Pré-requisitos
- Conta Databricks Free Edition
- Repositório clonado via Git Folders no Databricks Workspace

### 1. Clone o repositório
```bash
git clone https://github.com/matheusto/lakehouse-pipeline.git
```

### 2. Configure o ambiente
Execute `00_setup_ambiente.ipynb` para criar catálogo, schemas e volume.

### 3. Configure o dbt
Execute `00_setup_dbt.ipynb` e preencha `profiles.yml` com suas credenciais do SQL Warehouse.

### 4. Execute o pipeline
Notebooks em ordem numérica — cada um corresponde a uma camada Medallion.

### 5. Configure o Workflow
Job `lakehouse_pipeline_daily`:
`bronze_ingestion >> silver_transformation >> gold_dbt`

---

## 📅 Cronograma

| Sprint | Período | Status | Entregável |
|--------|---------|--------|-----------|
| Pré-Sprint | 18–23 Mar | ✅ | Ambiente, repositório, API explorada |
| Sprint 1 | 24–28 Mar | ✅ | Camada Bronze |
| Sprint 2 | 31 Mar–04 Abr | ✅ | Camada Silver com PySpark + Delta Lake |
| Sprint 3 | 07–11 Abr | ✅ | Camada Gold com dbt Core |
| Sprint 4 | 14–18 Abr | ✅ | Workflows + Dashboard + validação de dados |

---

## 👤 Autor

**Matheus Teodoro**
Data Engineer | Python · PySpark · Databricks · dbt · AWS · Azure

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Matheus%20Teodoro-blue?style=flat-square&logo=linkedin)](https://linkedin.com/in/mtoliveira)
[![GitHub](https://img.shields.io/badge/GitHub-matheusto-black?style=flat-square&logo=github)](https://github.com/matheusto)

---

## 📄 Licença

MIT License — sinta-se livre para usar como referência nos seus estudos.

---

> *"Construído durante transição estruturada para Engenharia de Dados.
> Cada decisão de arquitetura foi tomada com critério técnico e visão de mercado."*
