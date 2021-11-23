all: previews

ergogen/node_modules:
	cd ergogen; npm install

.PHONY: output
output: ergogen/node_modules silkscreens/edc.svg
	cd ergogen; node src/cli.js -o ../output ../variants/edc.yaml
	cd ergogen; node src/cli.js -o ../output ../variants/lasagna.yaml
	sed -i '' 's|.*pad.*||' output/pcbs/edc_shield.kicad_pcb

# sh -c 'cd /src/output/pcbs; pcbdraw edc_shield.kicad_pcb ../../previews/edc_shield.png; pcbdraw edc.kicad_pcb ../../previews/edc.png '

previews: output
	rm -f previews/*.png
	docker run --rm -it -v $(shell pwd):/src yaqwsx/kikit:nightly pcbdraw --style builtin:set-white-hasl.json /src/output/pcbs/edc_shield.kicad_pcb /src/previews/edc_shield_front.png
	docker run --rm -it -v $(shell pwd):/src yaqwsx/kikit:nightly pcbdraw --back --style builtin:set-white-hasl.json /src/output/pcbs/edc_shield.kicad_pcb /src/previews/edc_shield_back.png
	docker run --rm -it -v $(shell pwd):/src yaqwsx/kikit:nightly pcbdraw --style builtin:set-white-hasl.json /src/output/pcbs/edc.kicad_pcb /src/previews/edc_board.png

	docker run --rm -it -v $(shell pwd):/src yaqwsx/kikit:nightly pcbdraw --style builtin:set-white-hasl.json /src/output/pcbs/lasagna_shield.kicad_pcb /src/previews/lasagna_shield_front.png
	docker run --rm -it -v $(shell pwd):/src yaqwsx/kikit:nightly pcbdraw --back --style builtin:set-white-hasl.json /src/output/pcbs/lasagna_shield.kicad_pcb /src/previews/lasagna_shield_back.png
	docker run --rm -it -v $(shell pwd):/src yaqwsx/kikit:nightly pcbdraw --style builtin:set-white-hasl.json /src/output/pcbs/lasagna.kicad_pcb /src/previews/lasagna_board.png


silkscreens/edc.svg: 
	mkdir -p output
	svg2mod -x -i silkscreens/edc.svg -o output/edc.kicad_mod

freerouting.jar:
		wget -O freerouting.jar https://github.com/freerouting/freerouting/releases/download/v1.4.5/freerouting-1.4.5.jar

.PHONY: freerouting
freerouting: freerouting.jar output
	cp freerouting.rules output/pcbs/edc.rules
	java -jar freerouting.jar -de output/pcbs/edc.dsn -dr output/pcbs/edc.rules -do output/pcbs/edc.ses
	rm output/pcbs/*.bin	


