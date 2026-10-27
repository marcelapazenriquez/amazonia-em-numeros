# Amazônia em Números

Série de análises com dados públicos sobre Amazônia, clima e economia, por **Marcela Paz da Silva Enriquez**, economista paraense e mestranda em Ciências Econômicas (UFF), com foco em finanças verdes e desenvolvimento sustentável.

Todos os números vêm direto da fonte oficial. Este repositório traz os dados originais, a base organizada, o código e os gráficos, para que qualquer pessoa possa conferir e refazer a análise.

---

## #1. Desde 2023, o Cerrado perde mais vegetação que a Amazônia

<img src="graficos/01_amazonia_x_cerrado.png" width="55%" alt="Gráfico: desmatamento anual no Cerrado e na Amazônia, 2008 a 2025">

Na rota Rio–Belém, o avião cruza o Cerrado de Goiás e do Tocantins antes de chegar à floresta. A série do PRODES/INPE mostra o que essa paisagem esconde.

| Resultado | Valor |
|---|---|
| Anos (2008–2025) em que o Cerrado desmatou mais que a Amazônia | **11 de 18** |
| Período em que a Amazônia desmatou mais | **2016 a 2022** |
| Desmatamento na floresta amazônica, 2022 → 2026 | **12.474 → 3.363 km² (−73%)** |
| Participação do Cerrado no desmatamento do país em 2025 | **45%** (7.235 de 16.089 km²) | 
| Área desmatada acumulada, 2008–2025 | **Cerrado 168.339 km² × Amazônia 144.598 km²** |

<p>
  <img src="graficos/02_amazonia_serie.png" width="40%" alt="Gráfico: desmatamento anual na floresta amazônica, 2008 a 2026">
  <img src="graficos/03_biomas_2025.png" width="40%" alt="Gráfico: desmatamento por bioma em 2025">
</p>

---

## Como usar 

1. Nesta página, clique no botão verde **Code → Download ZIP**.
2. Descompacte na pasta **Downloads**. Evite Documentos e pastas do OneDrive, que podem bloquear o R ("Acesso negado").
3. Dentro da pasta, dê dois cliques em **`amazonia-em-numeros.Rproj`**. O RStudio abre já na pasta certa.
4. No **Console** do RStudio, cole e aperte Enter:

```r
source("R/prodes_biomas.R", encoding = "UTF-8")
```

O script instala sozinho os pacotes que faltarem, recria a base em `dados/` e os gráficos em `graficos/`, e mostra no Console a conferência:

```
================ CONFERÊNCIA DO POST #1 ================
1. Anos em que o Cerrado desmatou mais que a Amazônia: 11 de 18 ( 2008 a 2025 )
...
```

<details>
<summary><b>Não quer baixar nem descompactar? Use este atalho</b></summary>

Cole no Console do R. Ele baixa o repositório numa pasta temporária, roda tudo e abre a pasta com os resultados.

```r
pasta <- file.path(tempdir(), "amazonia")
dir.create(pasta, showWarnings = FALSE)
setwd(pasta)
download.file("https://github.com/marcelapazenriquez/amazonia-em-numeros/archive/refs/heads/main.zip",
              "repo.zip", mode = "wb")
unzip("repo.zip")
setwd("amazonia-em-numeros-main")
source("R/prodes_biomas.R", encoding = "UTF-8")
shell.exec(getwd())   # no Mac, use: system("open .")
```
</details>

---

## Conteúdo das pastas

| Pasta ou arquivo | O que é |
|---|---|
| [`dados/prodes_biomas.xlsx`](dados/prodes_biomas.xlsx) | Base completa em Excel, com conferência. **Comece por aqui.** |
| [`dados/prodes_biomas.csv`](dados/prodes_biomas.csv) | A mesma base em CSV, para R, Python ou Stata |
| [`dados/brutos/`](dados/brutos) | Arquivos originais do INPE, sem nenhuma alteração |
| [`R/prodes_biomas.R`](R/prodes_biomas.R) | Código que lê os arquivos do INPE, organiza a base e gera os gráficos |
| [`graficos/`](graficos) | Gráficos usados nos posts |
| [`posts/`](posts) | Texto e imagens de cada post publicado |
| `amazonia-em-numeros.Rproj` | Projeto do RStudio (abre o R na pasta certa) |

---

## Notas metodológicas

- **Fonte:** INPE/PRODES, painel *Incrementos de desmatamento* por bioma no [TerraBrasilis](https://terrabrasilis.dpi.inpe.br/app/dashboard/deforestation/biomes/amazon/increments). Em cada bioma: gráfico *Incrementos de desmatamento* → exportar CSV. Acesso em 16/10/2026.
- **Ano de referência:** vai de agosto do ano anterior a julho do ano indicado (2025 = ago/2024 a jul/2025).
- **Bioma Amazônia ≠ Amazônia Legal:** o recorte aqui é o bioma, separado em floresta e não floresta. A taxa da Amazônia Legal, mais citada na imprensa, inclui áreas de Cerrado e por isso é diferente.
- **Comparação Amazônia × Cerrado:** o PRODES Cerrado mede toda a vegetação nativa (savanas, campos e florestas). Por isso a Amazônia é comparada pela soma de floresta e não floresta. Usar só a floresta subestimaria a Amazônia.
- **2026:** só Amazônia (floresta) e Cerrado têm valor de 2026 no painel, e a série de não floresta termina em 2025. Por isso a comparação vai até 2025. Os valores de 2026 podem ser preliminares.
- **Mapeamento bienal:** nos primeiros anos, alguns biomas foram mapeados a cada dois anos e o INPE divide o valor igualmente entre os dois anos. Esses casos estão marcados na base e não têm variação anual calculada (nem o ano seguinte a eles).

---

## Posts da série

| # | Tema | Link |
|---|---|---|
| 1 | [Desde 2023, o Cerrado perde mais vegetação que a Amazônia](posts/01_cerrado_no_caminho_para_belem.md) | _(link do post)_ |

---

## Licença e como citar

Código sob licença MIT. Base organizada, gráficos e textos sob CC BY 4.0: pode reutilizar, desde que cite. Os dados originais são do INPE. Detalhes em [`LICENSE.md`](LICENSE.md).

> Enriquez, M. P. S. (2026). *Amazônia em Números #1: desmatamento por bioma, INPE/PRODES 2008–2026*. GitHub. https://github.com/marcelapazenriquez/amazonia-em-numeros

Sugestões ou correções: abra uma *issue* nesta página.
