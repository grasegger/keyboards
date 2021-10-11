all: output

ergogen/node_modules:
	cd ergogen; npm install --no-package-lock

.PHONY: output
output: ergogen/node_modules silk
	cd ergogen; node src/cli.js -o ../output ../anna.yaml

.PHONY: silk
silk: 
	svg2mod --convert-pads -i silk.svg -o silk.kicad_mod -p 0.01