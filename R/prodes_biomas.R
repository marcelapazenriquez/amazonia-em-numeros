# =====================================================================
#  Amazônia em Números #1 — Desmatamento por bioma (INPE/PRODES)
#  Autora: Marcela Paz da Silva Enriquez
#
#  COMO RODAR
#    1. Abra o arquivo amazonia-em-numeros.Rproj (duplo clique).
#    2. No Console do RStudio, cole e aperte Enter:
#         source("R/prodes_biomas.R", encoding = "UTF-8")
#
#  O QUE ESTE SCRIPT FAZ
#    1. Lê os 7 arquivos originais do INPE em dados/brutos/
#    2. Junta tudo numa tabela só e salva em dados/prodes_biomas.csv
#    3. Mostra no Console a conferência dos números do post
#    4. Gera os gráficos em graficos/
# =====================================================================


# ---- 0. Pacotes (instala sozinho o que faltar) ------------------------
pacotes  <- c("readr", "dplyr", "purrr", "stringr", "ggplot2")
faltando <- setdiff(pacotes, rownames(installed.packages()))
if (length(faltando) > 0) {
  message("Instalando pacotes: ", paste(faltando, collapse = ", "))
  install.packages(faltando)
}
suppressPackageStartupMessages({
  library(readr); library(dplyr); library(purrr); library(stringr); library(ggplot2)
})


# ---- 1. Ler os arquivos do INPE ---------------------------------------
# Cada arquivo foi exportado do painel "Incrementos de desmatamento" do
# TerraBrasilis e tem duas colunas: ano e área (km²), separadas por ";",
# com vírgula como separador decimal.
nomes <- c(amazon         = "Amazônia (floresta)",
           amazon_nf      = "Amazônia (não floresta)",
           cerrado        = "Cerrado",
           caatinga       = "Caatinga",
           mata_atlantica = "Mata Atlântica",
           pampa          = "Pampa",
           pantanal       = "Pantanal")

arquivos <- list.files("dados/brutos", pattern = "^prodes_.*\\.csv$", full.names = TRUE)
if (length(arquivos) == 0) {
  stop("\n\nNão encontrei os arquivos em dados/brutos/.\n",
       "A pasta de trabalho atual é: ", getwd(), "\n",
       "Abra o arquivo amazonia-em-numeros.Rproj e rode o script de novo.\n", call. = FALSE)
}

ler_prodes <- function(arquivo) {
  chave <- basename(arquivo) |> str_remove("^prodes_") |> str_remove("\\.csv$")
  bruto <- read_delim(arquivo, delim = ";", col_types = "cc",
                      locale = locale(encoding = "UTF-8"))
  names(bruto) <- c("ano", "area")
  tibble(
    bioma    = unname(nomes[chave]),
    ano      = as.integer(bruto$ano),
    area_km2 = parse_number(bruto$area,
                            locale = locale(decimal_mark = ",", grouping_mark = "."))
  )
}

prodes <- map_dfr(arquivos, ler_prodes)
message("Lidos ", length(arquivos), " arquivos do INPE (", nrow(prodes), " linhas).")


# ---- 2. Organizar a base ----------------------------------------------
# Mapeamento bienal: nos primeiros anos, alguns biomas foram mapeados a
# cada dois anos e o INPE divide o valor igualmente entre os dois anos.
# Nesses casos (e no ano seguinte a eles) não calculamos variação anual.
prodes <- prodes |>
  arrange(bioma, ano) |>
  group_by(bioma) |>
  mutate(
    mapeamento_bienal = if_else(area_km2 == lag(area_km2, default = -1) |
                                area_km2 == lead(area_km2, default = -1), "sim", "não"),
    variacao_pct = if_else(mapeamento_bienal == "não" &
                           lag(mapeamento_bienal, default = "não") == "não",
                           round(100 * (area_km2 / lag(area_km2) - 1), 2), NA_real_)
  ) |>
  ungroup() |>
  select(bioma, ano, area_km2, variacao_pct, mapeamento_bienal)

write_csv(prodes, "dados/prodes_biomas.csv", na = "")
message("Base salva em dados/prodes_biomas.csv")


# ---- 3. Conferência dos números do post -------------------------------
br <- function(x) format(round(x), big.mark = ".", decimal.mark = ",", trim = TRUE)
valor <- function(b, a) prodes$area_km2[prodes$bioma == b & prodes$ano == a]

# O PRODES Cerrado mede toda a vegetação nativa. Para comparar, a Amazônia
# soma floresta + não floresta. A série completa vai de 2008 a 2025.
amazonia_total <- prodes |>
  filter(str_starts(bioma, "Amazônia"), ano >= 2008) |>
  group_by(ano) |> filter(n() == 2) |>
  summarise(area_km2 = sum(area_km2), .groups = "drop") |>
  mutate(bioma = "Amazônia")
cerrado <- prodes |> filter(bioma == "Cerrado", ano %in% amazonia_total$ano)
comp <- inner_join(amazonia_total, cerrado, by = "ano", suffix = c("_am", "_ce"))

floresta   <- filter(prodes, bioma == "Amazônia (floresta)")
total_2025 <- sum(prodes$area_km2[prodes$ano == 2025])

cat("\n================ CONFERÊNCIA DO POST #1 ================\n")
cat("1. Anos em que o Cerrado desmatou mais que a Amazônia:",
    sum(comp$area_km2_ce > comp$area_km2_am), "de", nrow(comp),
    "(", min(comp$ano), "a", max(comp$ano), ")\n")
cat("   Anos em que a Amazônia desmatou mais:",
    paste(comp$ano[comp$area_km2_ce <= comp$area_km2_am], collapse = ", "), "\n")
cat("2. Amazônia (floresta): ", br(valor("Amazônia (floresta)", 2022)), "km² em 2022 ->",
    br(valor("Amazônia (floresta)", 2026)), "km² em 2026 (",
    round(100 * (valor("Amazônia (floresta)", 2026) / valor("Amazônia (floresta)", 2022) - 1)),
    "% )\n")
cat("   Menor valor da série desde 2008:", floresta$ano[which.min(floresta$area_km2)], "\n")
cat("3. Cerrado em 2025:", br(valor("Cerrado", 2025)), "de", br(total_2025), "km² =",
    round(100 * valor("Cerrado", 2025) / total_2025), "% do país\n")
cat("4. Acumulado", min(comp$ano), "-", max(comp$ano), ": Cerrado", br(sum(comp$area_km2_ce)),
    "km² | Amazônia", br(sum(comp$area_km2_am)), "km²\n")
cat("========================================================\n")
cat("Esperado: 11 de 18 | 12.474 -> 3.363 (-73%) | 45% | 168.339 x 144.598\n\n")


# ---- 4. Gráficos ------------------------------------------------------
dir.create("graficos", showWarnings = FALSE)
AM <- "#1baf7a"; CE <- "#eb6834"; FUNDO <- "#fcfcfb"; CINZA <- "#6b6a63"

rodape <- function(link) paste0(
  "Marcela Paz Enríquez · Amazônia em Números\n",
  "Fonte: INPE/PRODES. Painel \"Incrementos de desmatamento\" -> exportar CSV (extraído em 16/10/2026):\n",
  "terrabrasilis.dpi.inpe.br/app/dashboard/deforestation/biomes/", link, "\n",
  "Ano de referência: agosto do ano anterior a julho do ano indicado (ex.: 2025 = ago/2024-jul/2025).")

tema <- theme_minimal(base_size = 13) +
  theme(plot.background     = element_rect(fill = FUNDO, colour = NA),
        panel.grid.minor    = element_blank(),
        panel.grid.major.x  = element_blank(),
        plot.title          = element_text(face = "bold", size = 19),
        plot.subtitle       = element_text(colour = CINZA, margin = margin(b = 14)),
        plot.caption        = element_text(colour = CINZA, size = 7, hjust = 0, lineheight = 1.3),
        plot.title.position = "plot", plot.caption.position = "plot",
        axis.text           = element_text(colour = CINZA),
        legend.position     = "none",
        plot.margin         = margin(20, 20, 12, 20))
salvar <- function(grafico, arquivo) {
  ggsave(file.path("graficos", arquivo), grafico, width = 6, height = 7.5, dpi = 200, bg = FUNDO)
}

# Gráfico 1: Cerrado x Amazônia (vegetação nativa total), 2008-2025
g1_dados <- bind_rows(amazonia_total, select(cerrado, ano, area_km2, bioma))
g1 <- ggplot(g1_dados, aes(ano, area_km2, colour = bioma)) +
  annotate("rect", xmin = 2015.5, xmax = 2022.5, ymin = -Inf, ymax = Inf, fill = "#efeee9") +
  annotate("text", x = 2019, y = 2600, label = "2016–2022:\na Amazônia\nperdeu mais",
           size = 3.2, colour = CINZA, vjust = 0) +
  geom_line(linewidth = 1.1) + geom_point(size = 1.8) +
  geom_text(data = filter(g1_dados, ano == max(ano)),
            aes(label = paste0(bioma, "\n", br(area_km2), " km²")),
            hjust = 0, nudge_x = 0.4, fontface = "bold", size = 3.8, colour = "#1f1f1d") +
  scale_colour_manual(values = c("Amazônia" = AM, "Cerrado" = CE)) +
  scale_y_continuous(labels = br, limits = c(0, 14500)) +
  scale_x_continuous(breaks = c(2008, 2011, 2014, 2017, 2020, 2025),
                     expand = expansion(add = c(0.5, 4))) +
  labs(title = "Desde 2023, o Cerrado perde\nmais vegetação que a Amazônia",
       subtitle = paste0("Desmatamento anual, km² (Amazônia = floresta +\nnão floresta). ",
                         "Cerrado maior em ", sum(comp$area_km2_ce > comp$area_km2_am),
                         " de ", nrow(comp), " anos."),
       x = NULL, y = "km² desmatados por ano", caption = rodape("<bioma>/increments (2008-2025)")) +
  tema
salvar(g1, "01_amazonia_x_cerrado.png")

# Gráfico 2: série da floresta amazônica, 2008-2026
g2_dados <- filter(floresta, ano >= 2008)
g2 <- ggplot(g2_dados, aes(ano, area_km2, fill = ano == max(ano))) +
  geom_col(width = 0.78) +
  geom_text(data = filter(g2_dados, ano %in% c(2022, max(ano))), aes(label = br(area_km2)),
            vjust = -0.5, fontface = "bold", size = 3.8) +
  scale_fill_manual(values = c(`FALSE` = "#a9dcc6", `TRUE` = AM)) +
  scale_y_continuous(labels = br, limits = c(0, 14000)) +
  scale_x_continuous(breaks = seq(2008, 2026, 3)) +
  labs(title = "Amazônia: menor desmatamento\ndesde 2008",
       subtitle = "Bioma Amazônia (floresta), km². Queda de 73%\nentre 2022 e 2026.",
       x = NULL, y = "km² desmatados por ano", caption = rodape("amazon/increments")) +
  tema
salvar(g2, "02_amazonia_serie.png")

# Gráfico 3: todos os biomas em 2025
g3_dados <- filter(prodes, ano == 2025)
g3 <- ggplot(g3_dados, aes(area_km2, reorder(bioma, area_km2), fill = bioma == "Cerrado")) +
  geom_col(width = 0.7) +
  geom_text(aes(label = br(area_km2)), hjust = -0.15, size = 3.6) +
  scale_fill_manual(values = c(`FALSE` = "#c9c8c1", `TRUE` = CE)) +
  scale_x_continuous(labels = br, limits = c(0, 8800)) +
  labs(title = "Onde o Brasil desmatou\nem 2025",
       subtitle = paste0("km² por bioma. O Cerrado sozinho foi\n",
                         round(100 * valor("Cerrado", 2025) / total_2025),
                         "% do total (", br(total_2025), " km²)."),
       x = NULL, y = NULL, caption = rodape("<bioma>/increments (um arquivo por bioma)")) +
  tema +
  theme(panel.grid.major.y = element_blank(), panel.grid.major.x = element_line(),
        axis.text.y = element_text(colour = "#1f1f1d", size = 12))
salvar(g3, "03_biomas_2025.png")

message("Gráficos salvos em graficos/. Pronto!")
