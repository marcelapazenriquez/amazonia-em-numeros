# 🌳 Amazônia em Números

Dados abertos da série **Amazônia em Números**, publicada no LinkedIn e no Instagram por **Marcela Paz da Silva Enriquez**, economista paraense e mestranda em Ciências Econômicas (UFF), com foco em finanças verdes e risco climático.

Todos os números vêm **direto da fonte oficial**, com o dado bruto, o script de tratamento e os gráficos, para qualquer pessoa conferir e reproduzir.

---

## #1 — O Cerrado perde mais vegetação que a Amazônia

![Amazônia x Cerrado](graficos/01_amazonia_x_cerrado.png)

Na rota Rio–Belém, a janela do avião mostra primeiro o agro do Cerrado e depois a floresta amazônica. Os dados do INPE mostram o que essa paisagem esconde:

| | |
|---|---|
| 🟧 **15 de 19 anos** | Desde 2008, o Cerrado perdeu mais vegetação que a Amazônia em 15 anos. A exceção foi 2019–2022. |
| 🟩 **3.363 km²** | Desmatamento no bioma Amazônia em 2026, o menor da série desde 2008. |
| 📉 **−73%** | Queda na Amazônia entre o pico de 2022 (12.474 km²) e 2026. |
| 🟧 **45%** | Participação do Cerrado em todo o desmatamento do Brasil em 2025 (7.235 de 16.089 km²). |
| 🌎 **173.856 km²** | Vegetação perdida no Cerrado entre 2008 e 2026, contra 138.398 km² na Amazônia. |

<p>
  <img src="graficos/02_amazonia_serie.png" width="48%">
  <img src="graficos/03_biomas_2025.png" width="48%">
</p>

---

## Estrutura

```
dados/
  brutos/prodes_<bioma>.csv   ← exportados do TerraBrasilis, sem alteração
  prodes_biomas.csv           ← base tratada (bioma, ano, área, variação)
R/
  prodes_biomas.R             ← trata os brutos e gera os gráficos
graficos/                     ← PNGs 4:5 usados nos posts
```

Para reproduzir: abra o RStudio na pasta do repositório e rode `R/prodes_biomas.R`.

## Notas metodológicas

- **Fonte:** INPE/PRODES, painel de incrementos de desmatamento por bioma no [TerraBrasilis](https://terrabrasilis.dpi.inpe.br/app/dashboard/deforestation/biomes/amazon/increments), acesso em 16/10/2026.
- **Ano PRODES:** vai de agosto do ano anterior a julho do ano indicado (2026 = ago/2025 a jul/2026).
- **Bioma Amazônia ≠ Amazônia Legal.** Aqui o recorte é o bioma, separado em floresta e não floresta. A taxa da Amazônia Legal, mais citada na imprensa, inclui áreas de Cerrado e por isso é maior.
- **Mapeamento bienal:** nos primeiros anos, Cerrado, Caatinga, Mata Atlântica, Pampa e Pantanal foram mapeados a cada dois anos, e o valor aparece dividido igualmente entre os dois anos. Esses casos estão marcados na coluna `mapeamento_bienal` e não têm variação anual calculada.
- **2026:** só Amazônia (floresta) e Cerrado já têm valor de 2026 no painel. Confira no TerraBrasilis se o número ainda é preliminar antes de citá-lo como taxa consolidada.

## Posts da série

| # | Tema | Link |
|---|---|---|
| 1 | O Cerrado perde mais vegetação que a Amazônia | _(link do post)_ |

---

Dados públicos, organizados para fins educativos. Ao reutilizar, cite o INPE/PRODES como fonte.
Sugestões ou correções: abra uma *issue*.
