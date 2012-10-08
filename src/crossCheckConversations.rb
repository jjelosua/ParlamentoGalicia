# encoding: utf-8

# Extract all text from a single PDF
require 'fileutils'

LOG_SUBDIR = '../logs'
INPUT_FILES_SUBDIR = '../cleanConv/legislatura'
FileUtils.makedirs(LOG_SUBDIR)

$log_file = File.open("#{LOG_SUBDIR}/crossCheckConversations.log", 'w')
for legis in 4..8
  inputDir = "#{INPUT_FILES_SUBDIR}#{legis}"
  Dir.entries(inputDir).select{|f| f.match(/.*\.txt/)}.each do |doc|
  #Dir.entries(inputDir).select{|f| f.match(/D40008_conversations.txt/)}.each do |doc|
    input_file = File.open("#{inputDir}/#{doc}").readlines[0..-1]
    #puts "Processing: #{doc}"
    
    #run through the conversations to check using first method
    input_file.each_with_index do |line, line_number|
      #if the line matches the start of a conversation but has not been detected
      if line.match(/^(\s)*[OA] señor(a)? .{2,200}:/)
        $log_file.puts("#{doc}/Línea #{line_number+1} possible conversation undetected method1:\n\n#{line[0..120]}")
      end
    end # each line
    
    #run through the conversations to check using second method
    input_file.each_with_index do |line, line_number|
      if line.match(/^(\s)*[OA] señor(a)? [A-ZÁÉÍÓÚÜ]{2,}/)
        $log_file.puts("#{doc}/Línea #{line_number+1} possible conversation undetected method2:\n\n#{line[0..120]}")
      end
    end # each line
  end # each doc
  puts "Legislative period #{legis}: processed"
end #for legis
