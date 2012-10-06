# encoding: utf-8

require 'fileutils'

LOG_SUBDIR = '../logs'
INPUT_FILES_SUBDIR = '../cleanConv/legislatura'
OUTPUT_FILES_SUBDIR = '../catConv/legislatura'

log_file = File.open("#{LOG_SUBDIR}/categorizeConversations.log", 'w')
for legis in 4..4
  inputDir = "#{INPUT_FILES_SUBDIR}#{legis}"
  outputDir = "#{OUTPUT_FILES_SUBDIR}#{legis}"
  FileUtils.makedirs(outputDir)
  Dir.entries(inputDir).select{|f| f.match(/^.*\.txt$/)}.each do |doc|
  #Dir.entries(inputDir).select{|f| f.match(/D40015_cleanConv\.txt/)}.each do |doc|
    clean_file = File.open("#{outputDir}/#{doc.gsub(/_cleanConv\.txt/, '')}_catConv.txt", 'w')
    orig_text = File.open("#{inputDir}/#{doc}").readlines[0..-1]
    puts "procesando el documento: #{doc}"
  end # each doc
  puts "Procesados los documentos de la legislatura #{legis}"
end #for legis