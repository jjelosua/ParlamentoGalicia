# encoding: utf-8
require 'fileutils'

LOG_SUBDIR = '../logs'
INPUT_FILES_SUBDIR = '../pdfs/legislatura'
OUTPUT_FILES_SUBDIR = '../txt/legislatura'
FileUtils.makedirs(LOG_SUBDIR)

#We redirect the standard output and error to a log_file, we do so because 
#we are using a command-line tool and it is the easiest way to capture the
#information
$stdout.reopen("#{LOG_SUBDIR}/convertPdfTxt.log", "w")
$stdout.sync = true
$stderr.reopen($stdout)
#Loop through all the available legistative periods
for legis in 4..8
  inputDir = "#{INPUT_FILES_SUBDIR}#{legis}"
  outputDir = "#{OUTPUT_FILES_SUBDIR}#{legis}"
  FileUtils.makedirs(outputDir)
  Dir.entries(inputDir).select{|f| f.match(/.*\.pdf/)}.each do |doc|
    output_file = "#{outputDir}/#{doc.gsub(/\.pdf/, '')}_layout.txt"
    #Run the command line tool pdftotext to obtain the text from the pdf
    #the option (-layout) will try to retain the format of the original
    #pdf file. Important for the two column case.
    `pdftotext -enc UTF-8 -layout "#{inputDir}/#{doc}" "#{output_file}"`
    puts "#{output_file}: Created"
  end 
  puts "Legislative period #{legis}: processed"
end