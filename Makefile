default: main

main: main.native

%.native: 
	corebuild $@ -pkg async -pkg cohttp -pkg cohttp.async
	mv $@ $*

clean:
	rm -Rf _build/ *.native
