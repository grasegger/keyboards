all: output

ergogen/node_modules:
	cd ergogen; npm install

.PHONY: output
output: ergogen/node_modules silk
	cd ergogen; node src/cli.js -o ../output ../variants/edc.yaml
	sed -i '' 's|.*pad.*||' output/pcbs/edc_shield.kicad_pcb

# sh -c 'cd /src/output/pcbs; pcbdraw edc_shield.kicad_pcb ../../previews/edc_shield.png; pcbdraw edc.kicad_pcb ../../previews/edc.png '

previews: output
	docker run --rm -it -v $(shell pwd):/src yaqwsx/kikit:nightly pcbdraw --style builtin:set-white-hasl.json /src/output/pcbs/edc_shield.kicad_pcb /src/previews/edc_shield_front.png
	docker run --rm -it -v $(shell pwd):/src yaqwsx/kikit:nightly pcbdraw --back --style builtin:set-white-hasl.json /src/output/pcbs/edc_shield.kicad_pcb /src/previews/edc_shield_back.png


.PHONY: silk
silk: 
	mkdir -p output
	svg2mod -x -i silkscreens/edc.svg -o output/edc.kicad_mod

freerouting: output
	cp freerouting.rules output/pcbs/edc.rules
	java -jar freerouting.jar -de output/pcbs/edc.dsn -dr output/pcbs/edc.rules -do output/pcbs/edc.ses
	rm output/pcbs/*.bin	


