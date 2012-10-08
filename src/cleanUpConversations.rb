# encoding: utf-8

# Extract all text from a single PDF
require 'fileutils'

LOG_SUBDIR = '../logs'
INPUT_FILES_SUBDIR = '../conversations/legislatura'
OUTPUT_FILES_SUBDIR = '../cleanConv/legislatura'
FileUtils.makedirs(LOG_SUBDIR)

$log_file = File.open("#{LOG_SUBDIR}/cleanUpConversations.log", 'w')
for legis in 4..8
  inputDir = "#{INPUT_FILES_SUBDIR}#{legis}"
  outputDir = "#{OUTPUT_FILES_SUBDIR}#{legis}"
  FileUtils.makedirs(outputDir)
  Dir.entries(inputDir).select{|f| f.match(/.*\.txt/)}.each do |doc|
  #Dir.entries(inputDir).select{|f| f.match(/D40008_conversations.txt/)}.each do |doc|
    output_file = File.open("#{outputDir}/#{doc.gsub(/_conversations\.txt/, '')}_cleanConv.txt", 'w')
    input_file = File.open("#{inputDir}/#{doc}").readlines[0..-1]
    #puts "Processing: #{doc}"
    #This buffer will be used to merge together the lines the consecutive lines that need clean up
    buffer = ""
    #run through the conversations to clean them up
    input_file.each_with_index do |line, line_number|
      #if the line begins with lower case then merge with previous line
      if ((line_number+1 < input_file.length) && (input_file[line_number+1].match(/^[a-záéíóúñ]{2,}/)))
        if (buffer.length == 0)
          buffer = line.gsub(/\n/, '')
          #if the line ends in some punctuation mark put a space in the middle
          if buffer.match(/[a-z ]$/)
            buffer += input_file[line_number+1].gsub(/\n/, '')
          else
            buffer += " " + input_file[line_number+1].gsub(/\n/, '')
          end
        else
          $log_file.puts("#{doc}/Línea #{line_number+1} two lowercase lines in a row:\n#{input_file[line_number+1]}")
          #if the line ends in some punctuation mark put a space in the middle
          if buffer.match(/[a-z ]$/)
            buffer += input_file[line_number+1].gsub(/\n/, '')
          else
            buffer += " " + input_file[line_number+1].gsub(/\n/, '')
          end
        end
      else
        #If the buffer is not empty, copy it to the output and go to the next line
        if (buffer.length > 0)
          output_file.write("#{buffer}\n")
          buffer=""
          next
        end
        #If the buffer is empty just copy the line to the output
        output_file.write(line)
      end
    end # each line
  end # each doc
  puts "Legislative period #{legis}: processed"
end #for legis