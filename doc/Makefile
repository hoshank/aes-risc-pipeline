SOURCES = $(wildcard *.tex *.bib *.sty tex/*.tex)
TARGETS = paper.pdf

${TARGETS} : %.pdf : ${SOURCES}
	@TEXINPUTS="${TEXINPUTS}:./sty" pdflatex ${*}
	@TEXINPUTS="${TEXINPUTS}:./sty"   bibtex ${*}
	@TEXINPUTS="${TEXINPUTS}:./sty" pdflatex ${*}
	@TEXINPUTS="${TEXINPUTS}:./sty"   bibtex ${*}
	@TEXINPUTS="${TEXINPUTS}:./sty" pdflatex ${*}

all      : ${TARGETS}

clean    :
	@rm -f paper.{aux,bbl,bcf,blg,log,out,pdf,toc,xml}

spotless : clean
	@rm -f ${TARGETS}
