light:
	dhall-to-yaml --explain < variants/lasagna.dhall > output/lasagna.yaml
	cd ergogen; npm i --no-package-lock; node src/cli.js -o ../output ../output/lasagna.yaml

full:
	act -b