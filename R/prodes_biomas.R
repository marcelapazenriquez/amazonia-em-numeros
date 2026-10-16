# =====================================================================
#  Amazônia em Números #1 — Desmatamento por bioma (INPE/PRODES)
#  Autora: Marcela Paz da Silva Enriquez
#
#  Entrada : dados/brutos/prodes_<bioma>.csv
#            (exportados do TerraBrasilis > Desmatamento > Biomas > Incrementos)
#  Saída   : dados/prodes_biomas.csv  (base longa tratada)
#            graficos/*.png           (4:5, prontos para LinkedIn/Instagram)
#
#  Rode a partir da pasta raiz do repositório.
# =====================================================================

library(readr); library(dplyr); library(purrr); library(stringr); library(ggplot2)

nomes <- c(amazon = "Amazônia (floresta)", amazon_nf = "Amazônia (não floresta)",
           cerrado = "Cerrado", caatinga = "Caatinga",
           mata_atlantica = "Mata Atlântica", pampa = "Pampa", pantanal = "Pantanal")

ler_prodes <- function(arq) {
  chave <- str_remove(basename(arq), "^prodes_") |> str_remove("\\.csv$")
  read_delim(arq, delim = ";", show_col_types = FALSE,
             locale = locale(decimal_mark = ",", grouping_mark = ".")) |>
    setNames(c("ano", "area_km2")) |>
    mutate(bioma = nomes[[chave]], .before = 1)
}

prodes <- list.files("dados/brutos", "^prodes_.*\\.csv$", full.names = TRUE) |>
  map_dfr(ler_prodes) |>
  arrange(bioma, ano) |>
  group_by(bioma) |>
  mutate(
    # Nos primeiros anos, alguns biomas foram mapeados a cada 2 anos e o
    # INPE divide o valor igualmente entre os dois anos. Marcamos esses casos
    # e não calculamos variação anual neles.
    mapeamento_bienal = if_else(area_km2 == lag(area_km2, default = -1) |
                                area_km2 == lead(area_km2, default = -1), "sim", "não"),
    variacao_pct = if_else(mapeamento_bienal == "não",
                           round(100 * (area_km2 / lag(area_km2) - 1), 2), NA_real_)
  ) |>
  ungroup()

write_csv(prodes, "dados/prodes_biomas.csv", na = "")

# ---- Destaques para o post ------------------------------------------------
am <- filter(prodes, bioma == "Amazônia (floresta)")
ce <- filter(prodes, bioma == "Cerrado", ano >= 2008)
comp <- inner_join(am, ce, by = "ano", suffix = c("_am", "_ce"))

cat("Anos (desde 2008) em que o Cerrado perdeu mais que a Amazônia:",
    sum(comp$area_km2_ce > comp$area_km2_am), "de", nrow(comp), "\n")
cat("Amazônia — menor valor:", am$ano[which.min(am$area_km2)],
    "| queda 2022→2026:",
    round(100 * (am$area_km2[am$ano == 2026] / am$area_km2[am$ano == 2022] - 1), 1), "%\n")
t25 <- filter(prodes, ano == 2025)
cat("Participação do Cerrado em 2025:",
    round(100 * t25$area_km2[t25$bioma == "Cerrado"] / sum(t25$area_km2)), "%\n")

# ---- Gráficos -------------------------------------------------------------
AM <- "#1baf7a"; CE <- "#eb6834"; BG <- "#fcfcfb"; MUT <- "#6b6a63"
br <- function(x) format(round(x), big.mark = ".", decimal.mark = ",", trim = TRUE)
fonte <- "Fonte: INPE/PRODES (TerraBrasilis), acesso 16/10/2026. Ano PRODES = ago a jul.\nAmazônia em Números · @celapaz"

tema <- theme_minimal(base_size = 13) +
  theme(plot.background = element_rect(fill = BG, colour = NA),
        panel.grid.minor = element_blank(), panel.grid.major.x = element_blank(),
        plot.title = element_text(face = "bold", size = 19),
        plot.subtitle = element_text(colour = MUT, margin = margin(b = 14)),
        plot.caption = element_text(colour = MUT, size = 8.5, hjust = 0),
        plot.title.position = "plot", plot.caption.position = "plot",
        axis.text = element_text(colour = MUT), legend.position = "none",
        plot.margin = margin(20, 20, 12, 20))
salvar <- function(p, arq) ggsave(file.path("graficos", arq), p, width = 6, height = 7.5, dpi = 200)

# 1. Amazônia x Cerrado
d1 <- bind_rows(am, ce) |> mutate(rot = if_else(bioma == "Cerrado", "Cerrado", "Amazônia"))
p1 <- ggplot(d1, aes(ano, area_km2, colour = rot)) +
  annotate("rect", xmin = 2018.5, xmax = 2022.5, ymin = -Inf, ymax = Inf, fill = "#efeee9") +
  annotate("text", x = 2020.5, y = 14300, label = "2019–2022:\núnico período em que\na Amazônia perdeu mais",
           size = 3.2, colour = MUT, vjust = 1) +
  geom_line(linewidth = 1.1) + geom_point(size = 1.8) +
  geom_text(data = filter(d1, ano == max(ano)),
            aes(label = paste0(rot, "\n", br(area_km2), " km²")),
            hjust = 0, nudge_x = 0.4, fontface = "bold", size = 3.8, colour = "#1f1f1d") +
  scale_colour_manual(values = c(Amazônia = AM, Cerrado = CE)) +
  scale_y_continuous(labels = br, limits = c(0, 14500)) +
  scale_x_continuous(breaks = seq(2008, 2026, 3), expand = expansion(add = c(0.5, 4))) +
  labs(title = "O Cerrado perde mais vegetação\nque a Amazônia",
       subtitle = "Desmatamento anual, km². O Cerrado superou a\nAmazônia em 15 dos 19 anos desde 2008.",
       x = NULL, y = "km² desmatados por ano", caption = fonte) + tema
salvar(p1, "01_amazonia_x_cerrado.png")

# 2. Série da Amazônia
p2 <- ggplot(am, aes(ano, area_km2, fill = ano == max(ano))) +
  geom_col(width = 0.78) +
  geom_text(data = filter(am, ano %in% c(2022, max(ano))), aes(label = br(area_km2)),
            vjust = -0.5, fontface = "bold", size = 3.8) +
  scale_fill_manual(values = c(`FALSE` = "#a9dcc6", `TRUE` = AM)) +
  scale_y_continuous(labels = br, limits = c(0, 14000)) +
  scale_x_continuous(breaks = seq(2008, 2026, 3)) +
  labs(title = "Amazônia: menor desmatamento\ndesde 2008",
       subtitle = "Bioma Amazônia (floresta), km². Queda de 73%\nentre 2022 e 2026.",
       x = NULL, y = "km² desmatados por ano", caption = fonte) + tema
salvar(p2, "02_amazonia_serie.png")

# 3. Biomas em 2025
p3 <- ggplot(t25, aes(area_km2, reorder(bioma, area_km2), fill = bioma == "Cerrado")) +
  geom_col(width = 0.7) +
  geom_text(aes(label = br(area_km2)), hjust = -0.15, size = 3.6) +
  scale_fill_manual(values = c(`FALSE` = "#c9c8c1", `TRUE` = CE)) +
  scale_x_continuous(labels = br, limits = c(0, 8800)) +
  labs(title = "Onde o Brasil desmatou\nem 2025",
       subtitle = paste0("km² por bioma. O Cerrado sozinho foi\n",
                         round(100 * t25$area_km2[t25$bioma == "Cerrado"] / sum(t25$area_km2)),
                         "% do total (", br(sum(t25$area_km2)), " km²)."),
       x = NULL, y = NULL, caption = fonte) +
  tema + theme(panel.grid.major.y = element_blank(), panel.grid.major.x = element_line(),
               axis.text.y = element_text(colour = "#1f1f1d", size = 12))
salvar(p3, "03_biomas_2025.png")
