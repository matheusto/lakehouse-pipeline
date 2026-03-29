# 🏗️ Pipeline Lakehouse End-to-End

![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow?style=flat-square)
![Python](https://img.shields.io/badge/Python-3.11-blue?style=flat-square&logo=python)
![PySpark](https://img.shields.io/badge/PySpark-3.5-orange?style=flat-square&logo=apachespark)
![Databricks](https://img.shields.io/badge/Databricks-Free%20Edition-red?style=flat-square&logo=databricks)
![Delta Lake](https://img.shields.io/badge/Delta%20Lake-Medallion-00ADD8?style=flat-square)
![dbt](https://img.shields.io/badge/dbt-Core-FF694B?style=flat-square&logo=dbt)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=flat-square&logo=powerbi)
![Unity Catalog](https://img.shields.io/badge/Unity%20Catalog-Databricks-red?style=flat-square&logo=databricks)

> Pipeline de dados completo com arquitetura Medallion (Bronze / Silver / Gold),
> processamento distribuído com PySpark, modelagem com dbt Core e orquestração
> com Databricks Workflows — 100% na plataforma Databricks Free Edition.

---

## 🚦 Status do Projeto

| Camada | Status | Entregável |
|--------|--------|------------|
| Bronze | ✅ Concluída | Ingestão paginada da API + Volume particionado por data |
| Silver | 🔄 Sprint 2 — 31/03 | PySpark + Delta Lake particionado por state |
| Gold | ⬜ Sprint 3 — 07/04 | dbt Core + SQL Warehouse |
| Orquestração | ⬜ Sprint 4 — 14/04 | Databricks Workflows + Dashboard final |

---

## 📋 Sobre o Projeto

Este projeto foi construído como **projeto âncora de portfólio** durante minha transição de Suporte Técnico para Engenharia de Dados.

O objetivo é replicar uma arquitetura Lakehouse moderna cobrindo todo o ciclo: **ingestão → transformação → modelagem → orquestração → consumo**.

**Fonte de dados:** [Open Brewery DB API](https://www.openbrewerydb.org/) — API pública REST com dados de ~8.000 cervejarias dos EUA (localização, tipo, website, contato).

**Decisão de arquitetura:** todo o projeto roda 100% no Databricks Free Edition, utilizando Unity Catalog como metastore, Volumes para armazenamento Bronze, Delta Lake para Silver e Gold, e Databricks Workflows para orquestração — sem dependência de serviços externos como AWS S3 ou Apache Airflow.

---

## 🏛️ Arquitetura

```
Open Brewery DB API (~8.000 registros)
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
│  GOLD — dbt models                           │
│  mart_by_state / mart_by_type                │
│  Agregações analíticas prontas para consumo  │
└──────────────┬───────────────────────────────┘
               │
      ┌────────┴────────┐
      ▼                 ▼
Databricks          Power BI
Dashboard           Connector
(nativo)            (SQL Warehouse)
```

**Orquestração:** Databricks Workflows com Job multi-task e schedule diário cobrindo todas as camadas.

---

## 🛠️ Stack Técnica

| Camada | Tecnologia | Função |
|--------|-----------|--------|
| Ingestão | Python 3.11 + Requests | Coleta da API com paginação completa |
| Storage Bronze | Databricks Volumes + Unity Catalog | Armazenamento raw particionado por data |
| Processamento | PySpark | Transformações distribuídas Silver |
| Plataforma | Databricks Free Edition | Execução, catálogo e orquestração |
| Formato | Delta Lake | Tabelas ACID Silver e Gold |
| Modelagem | dbt Core | Transformações SQL + testes + lineage |
| Orquestração | Databricks Workflows | Agendamento e monitoramento do pipeline |
| Visualização | Databricks Dashboard + Power BI | Consumo analítico final |
| Catálogo | Unity Catalog | Governança e discovery de dados |
| Versionamento | Git + GitHub | Controle de versão integrado via Git Folders |

---

## 📁 Estrutura do Repositório

```
lakehouse-pipeline/
│
├── README.md
│
├── notebooks/                           ── PIPELINE ─────────────────────
│   ├── 00_setup_ambiente.py             ← Unity Catalog: catalog, schemas, volume
│   ├── 01_bronze_ingestao.py            ← Ingestão da API + save no Volume ✅
│   ├── 02_silver_transformacao.py       ← PySpark + Delta Lake (Sprint 2)
│   └── 03_gold_dbt.py                   ← Trigger dbt + validação (Sprint 3)
│
└── dbt_gold/                            ── GOLD ─────────────────────────
    ├── dbt_project.yml
    ├── profiles.yml.example
    └── models/
        ├── staging/
        │   └── stg_breweries.sql
        └── marts/
            ├── mart_by_state.sql
            └── mart_by_type.sql
```

---

## 📊 Camadas de Dados

### 🥉 Bronze — Dados Brutos ✅
- **Formato:** JSON particionado por data de ingestão
- **Storage:** `/Volumes/lakehouse_portfolio/bronze/breweries_raw/year=YYYY/month=MM/day=DD/data.json`
- **Princípio:** sem transformações — fidelidade total à fonte
- **Volume:** ~8.000 registros por execução

### 🥈 Silver — Dados Limpos *(Sprint 2)*
- **Formato:** Delta Lake particionado por `state`
- **Storage:** `lakehouse_portfolio.silver.breweries`
- **Transformações:** remoção de nulos, padronização de tipos, deduplicação

### 🥇 Gold — Dados Analíticos *(Sprint 3)*
- **Formato:** Delta Lake com modelos dbt
- **Modelos:** `mart_by_state`, `mart_by_type`
- **Conteúdo:** agregações por estado, por tipo de cervejaria, métricas geográficas

---

## 📈 Dashboard

O dashboard final conecta diretamente ao Delta Lake via Databricks SQL Connector e apresenta:

- 📍 Distribuição geográfica das cervejarias por estado
- 📊 Ranking Top 10 estados com mais cervejarias
- 🍺 Distribuição por tipo de cervejaria
- 📋 KPIs: total de cervejarias, estados cobertos, % com website

---

## 🚀 Como Reproduzir

### Pré-requisitos

- Conta Databricks Free Edition
- Python 3.11+
- dbt Core (`pip install dbt-databricks`)

### 1. Clone o repositório

```bash
git clone https://github.com/matheusteo/lakehouse-pipeline.git
cd lakehouse-pipeline
```

### 2. Configure o ambiente no Databricks

Execute o notebook `00_setup_ambiente.py` para criar o catálogo, schemas e volume no Unity Catalog.

### 3. Execute a ingestão Bronze

Execute o notebook `01_bronze_ingestao.py` — ele coleta a API e salva os dados no Volume automaticamente.

### 4. Continue pelas sprints

Siga os notebooks em ordem numérica. Cada um corresponde a uma camada da arquitetura Medallion.

---

## 📅 Cronograma de Desenvolvimento

| Sprint | Período | Status | Entregável |
|--------|---------|--------|-----------|
| Pré-Sprint | 18–23 Mar | ✅ | Ambiente, repositório, API explorada |
| Sprint 1 | 24–28 Mar | ✅ | Camada Bronze funcionando |
| Sprint 2 | 31 Mar–04 Abr | 🔄 | Camada Silver com PySpark + Delta Lake |
| Sprint 3 | 07–11 Abr | ⬜ | Camada Gold com dbt |
| Sprint 4 | 14–18 Abr | ⬜ | Workflows + Dashboard + README final |

---

## 👤 Autor

**Matheus Teodoro**
Data Engineer | Python · PySpark · Databricks · AWS · Azure

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Matheus%20Teodoro-blue?style=flat-square&logo=linkedin)](https://linkedin.com/in/matheus-teodoro)
[![GitHub](https://img.shields.io/badge/GitHub-matheusteo-black?style=flat-square&logo=github)](https://github.com/matheusteo)

---

## 📄 Licença

MIT License — sinta-se livre para usar como referência nos seus estudos.

---

> *"Construído como projeto de portfólio durante transição para Engenharia de Dados.  
> Cada linha de código representa aprendizado prático aplicado."*
