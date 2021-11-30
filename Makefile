light: ergogen/node_modules
	dhall-to-yaml --explain < variants/lasagna.dhall > output/lasagna.yaml
	cd ergogen; node src/cli.js -o ../output ../output/lasagna.yaml

	sed -i -e 's|.*pad.*||' output/pcbs/lasagna_shield.kicad_pcb
	sed -i -e 's|.*Dwgs.User.*||' output/pcbs/lasagna_shield.kicad_pcb
#	open output/pcbs/lasagna.kicad_pcb
	open output/pcbs/lasagna_shield.kicad_pcb

ergogen/node_modules:
	cd ergogen; npm i --no-lockfile

full:
	act -b