#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 results_path"
  exit
fi

./process/analysis.rb $1

cd statistics
./statistics.R $1
cd ..

for file in $1/figures/*.pdf ; do
  gs -q -sFONTPATH=/usr/share/texmf/fonts/opentype/public/tex-gyre/ -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -o "$file.new" "$file"
  mv "$file.new" "$file"
done
