light: ergogen/node_modules
	dhall-to-yaml --explain < variants/lasagna.dhall > output/lasagna.yaml
	cd ergogen; node src/cli.js -o ../output ../output/lasagna.yaml
	open output/pcbs/lasagna.kicad_pcb

ergogen/node_modules:
	cd ergogen; npm i --no-lockfile

full:
	act -b