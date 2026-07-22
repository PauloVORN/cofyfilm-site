#!/bin/bash
# Gera derivados AVIF/WebP (480/800/1200px) de cada JPG das galerias +
# WebP dos logos, e escreve _data/img_dimensions.yml com as dimensões
# dos originais (usado pelos includes pra width/height, CLS zero).
# Rodar de novo sempre que entrar foto nova. Requer ffmpeg com
# libaom-av1 e libwebp (ex.: winget install Gyan.FFmpeg).
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

WINGET_FFMPEG="$LOCALAPPDATA/Microsoft/WinGet/Packages/Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-8.1.2-full_build/bin/ffmpeg.exe"
WINGET_FFPROBE="$LOCALAPPDATA/Microsoft/WinGet/Packages/Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe/ffmpeg-8.1.2-full_build/bin/ffprobe.exe"
FFMPEG="$(command -v ffmpeg || echo "$WINGET_FFMPEG")"
FFPROBE="$(command -v ffprobe || echo "$WINGET_FFPROBE")"

IMGDIR="$REPO_ROOT/assets/img"
DATAFILE="$REPO_ROOT/_data/img_dimensions.yml"
WIDTHS="480 800 1200"

echo "# Gerado por scripts/build-img-derivatives.sh — dimensoes dos originais (para width/height, CLS zero)" > "$DATAFILE"

process_one() {
  local jpg="$1"
  local relpath="$2"
  local dir
  dir=$(dirname "$jpg")
  local base
  base=$(basename "$jpg" .jpg)

  local dims w h
  dims=$("$FFPROBE" -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$jpg")
  w=$(echo "$dims" | cut -d, -f1)
  h=$(echo "$dims" | cut -d, -f2)
  printf '"%s":\n  width: %s\n  height: %s\n' "$relpath" "$w" "$h" >> "$DATAFILE"

  for W in $WIDTHS; do
    "$FFMPEG" -y -i "$jpg" -vf "scale='min($W,iw)':-2" -c:v libaom-av1 -crf 30 -b:v 0 -cpu-used 6 "$dir/${base}-${W}.avif" </dev/null > /dev/null 2>&1
    "$FFMPEG" -y -i "$jpg" -vf "scale='min($W,iw)':-2" -c:v libwebp -quality 78 "$dir/${base}-${W}.webp" </dev/null > /dev/null 2>&1
  done
  echo "ok: $relpath ($w x $h)"
}

for folder in retrato arquitetura industrial eventos; do
  for jpg in "$IMGDIR/$folder"/*.jpg; do
    process_one "$jpg" "/assets/img/$folder/$(basename "$jpg")"
  done
done

process_one "$IMGDIR/equipe_cofyfilm.jpg" "/assets/img/equipe_cofyfilm.jpg"

echo "=== Convertendo logos para WebP ==="
for png in "$IMGDIR/logos"/*.png; do
  base=$(basename "$png" .png)
  "$FFMPEG" -y -i "$png" -c:v libwebp -quality 85 "$IMGDIR/logos/${base}.webp" </dev/null > /dev/null 2>&1
  echo "ok: logos/${base}.webp"
done

echo "=== FEITO ==="
