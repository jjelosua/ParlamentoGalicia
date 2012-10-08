# encoding: utf-8

# Extract all text from a single PDF
require 'fileutils'

LOG_SUBDIR = '../logs'
INPUT_FILES_SUBDIR = '../serialized_txt/legislatura'
OUTPUT_FILES_SUBDIR = '../restored_txt/legislatura'
FileUtils.makedirs(LOG_SUBDIR)

$log_file = File.open("#{LOG_SUBDIR}/restoreLines.log", 'w')
for legis in 4..8
  inputDir = "#{INPUT_FILES_SUBDIR}#{legis}"
  outputDir = "#{OUTPUT_FILES_SUBDIR}#{legis}"
  FileUtils.makedirs(outputDir)
  Dir.entries(inputDir).select{|f| f.match(/.*\.txt/)}.each do |doc|
  #Dir.entries(inputDir).select{|f| f.match(/D40011_serialized.txt/)}.each do |doc|
    output_file = File.open("#{outputDir}/#{doc.gsub(/_serialized\.txt/, '')}_restored.txt", 'w')
    input_file = File.open("#{inputDir}/#{doc}").readlines[0..-1]
    #run through the lines to clean them up
    input_file.each_with_index do |line, line_number|
      #If we think this maybe the start of a Conversation
      #Make sure it starts at the beggining of a line on the output
      if line.match(/(^(\s)*O señor [A-ZÁÉÍÓÚ]{2,})|((\s)*^A señora [A-ZÁÉÍÓÚ]{2,})/)
        output_file.write("\n")
      end
      
      #We get rid of lines with only a number since it comes from the heading of pages
      if line.match(/^(\s)*[0-9]+(\s)*$/) 
        $log_file.puts("#{doc}: Page Number #{line}")
        next
      end
      
      #Clean up multiple empty lines together
      if ((line.match(/^\n$/)) && line_number+1 < input_file.length &&input_file[line_number+1].match(/^\n$/))
        #puts "Línea #{line_number+1}: Is just a carriage return and the next one too"
        next
      end
      
      #TODO clean up this is really messy probably some of the cases are not correctly treated
      #If we have a period inside a line split into two lines on the output
      if (line.match(/.+\. [A-ZÁÉÍÓÚ]{1}.+/))
      #if (line.match(/.+\. [A-ZÁÉÍÓÚ]{1}[a-záéíóúñ]{1,}.+/))
        #puts "Línea #{line_number+1}: Has a period on the middle"
        #If the period comes from an abreviattion ignore it
        if line.match(/(Sr|D|Sra|Da|[A-Z]|[0-9])\./)
          aux = line
        else
          pos = line.index('.',1)
          output_file.write("#{line[0,pos+1]}\n")
          aux = line[pos+2,line.length]
        end
      else
        aux = line
      end
      
      #If the line finishes in a hyphen get rid of that and the newline and continue on output
      if (aux.match(/-\n$/))
        #puts "Línea #{line_number+1}: Ends in hyphen"
        output_file.write(aux[0,aux.length-2])
      #If the line finishes in a punctuation mark that denotes a new line just copy it to the output
      elsif (aux.match(/(\.|:|\]|\)|\?)\n$/))
        #puts "Línea #{line_number+1}: Ends in period or colon"
        output_file.write(aux)
      #If the ending of the line doesn't match any of the previous endings 
      #then just concatenate it with the next one on the output using spaces
      elsif (aux.match(/.\n$/))
        output_file.write("#{aux.strip} ")
      else 
        if (aux.match(/^\n$/))
          #Skip this empty line since it comes from the two column bad alligment
          next
        else
          $log_file.puts("#{doc}: Check which case is scaping control #{line_number+1}")
        end
      end
    end # each line
  end # each doc
  puts "Legislative period #{legis}: processed"
end #for legis