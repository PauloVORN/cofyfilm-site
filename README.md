# cofyfilm.com.br — site Jekyll

Site estático da Cofy Film, feito em Jekyll pra hospedagem no GitHub Pages (custo zero).

## Rodar localmente

```
bundle install
bundle exec jekyll serve
```

Abre em `http://localhost:4000`.

## Publicar no GitHub Pages

1. Criar repositório no GitHub e subir esta pasta.
2. Settings → Pages → Source: branch `main`, pasta `/ (root)`.
3. Settings → Pages → Custom domain: `cofyfilm.com.br` (cria o arquivo `CNAME` automaticamente) e apontar o DNS do domínio pros IPs do GitHub Pages.

O `sitemap.xml` e as meta tags de SEO são gerados automaticamente pelos plugins `jekyll-sitemap` e `jekyll-seo-tag` (ambos suportados nativamente pelo GitHub Pages).

## Estrutura

- `_layouts/default.html` — layout único (head + header + footer + lightbox)
- `_includes/` — schema.org JSON-LD, header, footer, CTA de WhatsApp, galeria, logos de clientes
- `assets/img/{retrato,industrial,arquitetura,eventos}/` — as galerias são montadas automaticamente a partir dos arquivos dessas pastas (basta adicionar/remover fotos, sem tocar em código)
- `assets/img/logos/` — logos de prova social (mesma lógica: soltar o PNG na pasta já inclui no site)

## Design system (handoff seção 8)

Paleta escura VornHaus (`--bk/--ash/--co/--em/--ch`), Cormorant Garamond + Helvetica Neue,
grain SVG fixo sobre o site inteiro. Wordmark tipográfico "COFY FILM" (claquete aposentada).
A animação de entrada do hero roda 1x por sessão, só na Home (`sessionStorage.cofyIntroPlayed`).

Galerias em masonry (`column-count`) — nenhuma foto é cortada. As capas de cada categoria
ficam em `_data/portfolio.yml` (campo `capa`), usadas no card da Home e em destaque nas
páginas internas antes da galeria.

## Tráfego pago (handoff seção 10)

- Imagens comprimidas (187 MB → 14 MB, max 1920px) + `loading="lazy"` em todas.
- `/politica-de-privacidade/` no ar e linkada no rodapé.
- Tag Google Ads + conversão no clique do WhatsApp: preencher `google_ads_id` e
  `google_ads_conversion_label` no `_config.yml` — enquanto vazios, nenhum script carrega.

## Arquitetura x Indústria (handoff seção 2)

Desmembradas em páginas próprias (`/arquitetura/` e `/industria/`) — públicos e SEO
diferentes demais pra uma página só. `/industria-e-arquitetura/` nunca chegou a ficar
pública, então foi removida sem redirect (404 puro, decisão explícita).

## SEO por página (spec técnica seções 1 e 2.2)

- `<title>` e meta description exatos da spec em cada página via front matter
  `meta_title:` (sobrepõe o `{% seo %}` com `title=false` — ver `_layouts/default.html`)
  + `description:`.
- Schema.org `Service` próprio em cada uma das 5 páginas de serviço (`service_type:` no
  front matter → `_includes/service-schema.html`), além do `ProfessionalService` global
  em `_includes/schema.html`.
- Duas divergências propositais da spec (documentando a decisão): a descrição de
  `/portfolio/` na spec cita "institucional" (que não tem galeria ali) e omite
  "arquitetura" — corrigi pra listar as 4 categorias que realmente aparecem na página.

## Pendências (do handoff)

1. **2 reels (institucional + drone)** — `institucional.html` tem dois placeholders com instrução de substituição no comentário HTML.
2. **Redirects — APLICADOS** (mapa `mapa-redirect-cofyfilm-FINAL.xlsx`, 48× 301 + 29× 410):
   - 301 interno: `redirect_from` no front matter das páginas de destino (institucional, retratos, eventos, indústria, contato, sobre, portfólio)
   - 301 externo (paulohlima.com.br): 26 páginas `redirect_to` em `redirects/`
   - 3 URLs eram no-op (mesmo path na arquitetura nova): home, /portfolio, /contato
   - 410: GitHub Pages não emite 410 de servidor — essas URLs retornam 404, que o Google trata de forma equivalente pra desindexação
   - Pendências do próprio mapa: atualizar pins do Pinterest da campanha de carnaval (ID 137859) pra nova URL; mapa do paulohlima fica pra quando aquele site for construído
3. ~~Foto AGAPICEATH~~ — **resolvido:** fica de fora da Arquitetura (nunca foi incluída).
4. ~~Logo Triunfo Logística~~ — **resolvido:** não usar (cliente do cliente, sem autorização direta).
5. **Modelo de dados do portfólio** — a spec técnica (seção 3) propõe uma collection
   `_portfolio/` com um arquivo por case/cliente (múltiplas galerias por categoria). O
   site atual usa o modelo mais simples de `_data/portfolio.yml` (uma capa + uma galeria
   por categoria), porque as fotos hoje não estão organizadas por case individual. Migrar
   pro modelo completo é possível quando houver cases distintos pra separar dentro de
   uma mesma categoria (ex: vários clientes de retrato com galeria própria cada).
6. **Fotos originais** — as imagens em `assets/img/` foram recomprimidas pra web; os arquivos em alta seguem nas pastas originais fora de `cofyfilm-site/`.
