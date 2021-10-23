all: docker

ergogen/node_modules:
	cd ergogen; npm install --no-package-lock

.PHONY: output
output: ergogen/node_modules silk
	cd ergogen; node src/cli.js -o ../output ../tippers/anna.yaml

.PHONY: silk
silk: 
	mkdir -p output
	svg2mod -i tippers/anna.svg -o output/anna.kicad_mod -p 0.1

watch: output
	fswatch -o tippers | xargs -n1 -I{} make

export: output
	rm -f output/pcbs/anna.dsn
	python3 create_dsn_export.py output/pcbs/anna.kicad_pcb .
	cd output/pcbs;  /opt/freerouting_cli/bin/freerouting_cli -de anna.dsn -do anna.ses -ap 100 -ds ../../autoroute_vias.rules
	python3 import_ses_to_kicad.py output/pcbs/anna.kicad_pcb .

docker:
	docker build -t keeb . 
	docker run --rm -it -v $(shell pwd):/mount keeb