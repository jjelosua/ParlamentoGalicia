# encoding: utf-8
require 'open-uri'
require 'fileutils'

# Galician Parlament session catalog
BASE_LIST_URL = 'http://www.parlamentodegalicia.es/sitios/web/BibliotecaDiarioSesions/'
#Arrays with number of documents per type of document, we include the prefix so we can access by prefix
doctypeD = ['D',130,142,170,152,0,0,155,142]
doctypeDD = ['DD',0,0,0,0,9,10,7,0]
doctypeDP = ['DP',0,0,0,0,155,153,79,4]

LOG_SUBDIR = '../logs'
OUTPUT_FILES_SUBDIR = '../pdfs/legislatura'
FileUtils.makedirs(LOG_SUBDIR)


def extractDocs (legis, array) 
  num = array[legis]
  if num != 0
    prefix = array[0];
    for ds in 1..num
      formDoc = "%04d" % (ds)
      #puts "#{BASE_LIST_URL}#{prefix}#{legis}#{formDoc}.pdf"
      begin
        pdf = open("#{BASE_LIST_URL}#{prefix}#{legis}#{formDoc}.pdf")
        # create a new file into to which we copy the doc contents
        file = File.open("#{OUTPUT_FILES_SUBDIR}#{legis}/#{prefix}#{legis}#{formDoc}.pdf", 'w'){|f| f.write(pdf.read)}
        # wait 2 seconds before getting the next doc, to not overburden the website.
        sleep 2
      rescue OpenURI::HTTPError => the_error
        # the_error.message is the numeric code and text in a string
        $log_file.puts("#{BASE_LIST_URL}#{prefix}#{legis}#{formDoc}.pdf: Got a bad status code #{the_error.message}")
        next
      end   
    end
  end
end

$log_file = File.open("#{LOG_SUBDIR}/scrapePdfs.log", 'w')
#Loop through all the available legistative periods 
for legis in 1..8
  outputDir = "#{OUTPUT_FILES_SUBDIR}#{legis}"
  FileUtils.makedirs(outputDir)
  #Extract normal session transcriptions
  extractDocs(legis,doctypeD)
  #Extract permanent session transcriptions
  extractDocs(legis,doctypeDD)
  #Extract other permanent session transcriptions
  extractDocs(legis,doctypeDP)
  puts "Legislative period #{legis}: processed"
end