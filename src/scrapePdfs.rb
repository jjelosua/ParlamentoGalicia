# encoding: utf-8

# Call Ruby's OpenURI module which gives us a method to 'open' a specified webpage
require 'open-uri'

# Biblioteca de diario de sesiones del parlamento de galicia.
BASE_LIST_URL = 'http://www.parlamentodegalicia.es/sitios/web/BibliotecaDiarioSesions/'
#Arrays con número de documentos por tipo, incluimos el cero para poder acceder por indice
doctypeD = ['D',130,142,170,152,0,0,155,142]
doctypeDD = ['DD',0,0,0,0,9,10,7,0]
doctypeDP = ['DP',0,0,0,0,155,153,79,4]

# create a subdirectory called 'pdfs'
LIST_PDF_SUBDIR = '../pdfs'

Dir.mkdir(LIST_PDF_SUBDIR) unless File.exists?(LIST_PDF_SUBDIR)

def extractDocs (legis, array) 
  num = array[legis]
  if num != 0
    prefix = array[0];
    for ds in 1..num
  		formDoc = "%04d" % (ds)
  		puts "#{BASE_LIST_URL}#{prefix}#{legis}#{formDoc}.pdf"
  		begin
  		  pdf = open("#{BASE_LIST_URL}#{prefix}#{legis}#{formDoc}.pdf")
  		  # create a new file into to which we copy the doc contents
  		  file = File.open("#{LIST_PDF_SUBDIR}/#{prefix}#{legis}#{formDoc}.pdf", 'w'){|f| f.write(pdf.read)}
  		  # wait 2 seconds before getting the next doc, to not overburden the website.
  		  sleep 2
  		rescue OpenURI::HTTPError => the_error
  		  # the_error.message is the numeric code and text in a string
        puts "Got a bad status code #{the_error.message}"
        next
  		end
  		   
  	end
  end
end

#Iteramos en las legislaturas disponibles (1 a 8)
for legis in 8..8
	#Extraemos los documentos de la Sesión plenaria
	extractDocs(legis,doctypeD)
	#Extraemos los documentos de la Sesión da Deputación Permanente
	extractDocs(legis,doctypeDD)
	#Extraemos los documentos de la Sesión da Deputación Permanente
	extractDocs(legis,doctypeDP)
end