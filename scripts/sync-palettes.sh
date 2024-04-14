#!/bin/bash

read -r -d '' AWKSCRIPT <<EOD
BEGIN {
  finishedPreamble=0
  finishedHeader=0
}

/^[^#]/ {
  if (finishedPreamble==1 && finishedHeader==0) {
    finishedHeader=1
    print "0\t0\t0\tTransparent"
  }
}

!/^(#Colors: [0-9]+)$/ {
  print \$0
}
/^#Colors: / {
  print \$1, \$2 + 1
}

/^GIMP Palette/ {
  finishedPreamble=1
}
EOD

#echo "$AWKSCRIPT"
OUTDIR="$HOME/.local/share/Steam/steamapps/common/Aseprite/data/extensions/arne-palettes"

for file in ~/downloads/assets/palettes/*.gpl; do
  echo "$filename"
  filename="$(basename "$file" )"
  #awk "$AWKSCRIPT" "$file" | tr -d '\r'
  #awk "$AWKSCRIPT" "$file" | tr -d '\r' > "${OUTDIR}/$filename"
  #echo -e "\n\n" >> "${OUTDIR}/$filename"
  palname=${filename%%.*}
  palname=${palname^}
  echo "$filename: $palname"
  inPackage="$(jq -r "any(.contributes.palettes[]; .id == \"$palname\")" "${OUTDIR}/package.json" )"
  if [[ "$inPackage" == "false" ]]; then
    jq ".contributes.palettes |= . + [{ \"id\": \"$palname\", \"path\": \"./$filename\"}]" "${OUTDIR}/package.json" > "${OUTDIR}/package.new.json" \
      && mv "${OUTDIR}/package.new.json" "${OUTDIR}/package.json"
  fi
done
