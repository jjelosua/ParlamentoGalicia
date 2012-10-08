# encoding: utf-8

require 'fileutils'

LOG_SUBDIR = '../logs'
INPUT_FILES_SUBDIR = '../cleanConv/legislatura'
OUTPUT_FILES_SUBDIR = '../final'

$log_file = File.open("#{LOG_SUBDIR}/categorizeConversations.log", 'w')
for legis in 4..8
  inputDir = "#{INPUT_FILES_SUBDIR}#{legis}"
  outputDir = "#{OUTPUT_FILES_SUBDIR}"
  FileUtils.makedirs(outputDir)
  output_file = File.open("#{outputDir}/conv_legis#{legis}.txt", 'w')
  tot_num_conv = 0
  Dir.entries(inputDir).select{|f| f.match(/^.*\.txt$/)}.each do |doc|
  #Dir.entries(inputDir).select{|f| f.match(/D40015_cleanConv\.txt/)}.each do |doc|
    input_file = File.open("#{inputDir}/#{doc}").readlines
    input_file.each_with_index do |line, line_number|
      if (line.match(/^\[[4-8];/))
        tot_num_conv += 1
      end
    output_file.write(line)  
    end
  end # each doc
  $log_file.write("We have detected #{tot_num_conv} in the legistative period #{legis}\n")
  puts "Legislative period #{legis}: processed"
end #for legis