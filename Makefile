all: lasagna
	rm *.ogv

ergogen/node_modules:
	cd ergogen; npm install

output:
	mkdir -p output

previews:
	mkdir -p previews

pre-cleanup: output previews
	rm -rf output/*
	rm -rf previews/*

.PHONY: lasagna
lasagna: output/pcbs/lasagna.kicad_pcb

.PHONY: output/pcbs/lasagna.kicad_pcb
output/pcbs/lasagna.kicad_pcb: pre-cleanup ergogen/node_modules output/lasagna.yaml
	cd ergogen; node src/cli.js -o ../output ../output/lasagna.yaml

.PHONY: preview-lasagna
preview-lasagna: previews/lasagna_shield_front.png previews/lasagna_shield_back.png previews/lasagna_board.png

previews/lasagna_shield_front.png: lasagna-import-ses
#	docker run --rm -it -v $(shell pwd):/src yaqwsx/kikit:nightly pcbdraw --style builtin:jlcpcb-green-hasl.json /src/output/pcbs/lasagna_shield.kicad_pcb /src/previews/lasagna_shield_front.png
	
previews/lasagna_shield_back.png: lasagna-import-ses
#	docker run --rm -it -v $(shell pwd):/src yaqwsx/kikit:nightly pcbdraw --back --style builtin:jlcpcb-green-hasl.json /src/output/pcbs/lasagna_shield.kicad_pcb /src/previews/lasagna_shield_back.png
	
previews/lasagna_board.png: lasagna-import-ses
	docker run --rm -it -v $(shell pwd):/src yaqwsx/kikit:nightly pcbdraw --style builtin:jlcpcb-green-hasl.json /src/output/pcbs/lasagna.kicad_pcb /src/previews/lasagna_board_front.png
	docker run --rm -it -v $(shell pwd):/src yaqwsx/kikit:nightly pcbdraw --back --style builtin:jlcpcb-green-hasl.json /src/output/pcbs/lasagna.kicad_pcb /src/previews/lasagna_board_back.png
	cd previews; mogrify -bordercolor transparent -border 20 -format png lasagna_board_*.png
	cd previews; montage -geometry +0+0 lasagna_board_front.png lasagna_board_back.png lasagna_board.png
	rm previews/lasagna_board_*.png 

freerouting.jar:
	wget -O freerouting.jar https://github.com/freerouting/freerouting/releases/download/v1.4.5/freerouting-1.4.5.jar

output/pcbs/lasagna.ses: freerouting.jar output/pcbs/lasagna.kicad_pcb output/pcbs/lasagna.dsn
	cp freerouting.rules output/pcbs/lasagna.rules
	java -jar freerouting.jar -de output/pcbs/lasagna.dsn -dr output/pcbs/lasagna.rules -do output/pcbs/lasagna.ses
	rm output/pcbs/*.bin
	rm output/pcbs/*.rules
	rm -f logs || true

output/pcbs/lasagna.dsn: docker-image
	docker run --rm -v $(shell pwd):/src -it anna-keebs:local export_dsn.py lasagna

.PHONY: lasagna-import-ses
lasagna-import-ses: output/pcbs/lasagna.ses
	docker run --rm -v $(shell pwd):/src -it anna-keebs:local import_dsn.py lasagna
	rm output/pcbs/lasagna.ses

.PHONY: docker-image
docker-image:
	docker build -t anna-keebs:local .

.PHONY: lasagna
lasagna: preview-lasagna

output/lasagna.yaml: output
	dhall-to-yaml --explain < variants/lasagna.dhall > output/lasagna.yaml