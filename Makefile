light: ergogen/node_modules
	dhall-to-yaml --explain < variants/weirdo.dhall > output/weirdo.yaml
	cd ergogen; node src/cli.js -o ../output ../output/weirdo.yaml
	open output/pcbs/weirdo.kicad_pcb

ergogen/node_modules:
	cd ergogen; npm i --no-lockfile

full:
	act -b