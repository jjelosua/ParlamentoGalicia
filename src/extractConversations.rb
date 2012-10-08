# encoding: utf-8
require 'fileutils'
require 'csv'

LOG_SUBDIR = '../logs'
INPUT_FILES_SUBDIR = '../restored_txt/legislatura'
DATES_FILES_SUBDIR = '../dates/legislatura'
OUTPUT_FILES_SUBDIR = '../conversations/legislatura'
FileUtils.makedirs(LOG_SUBDIR)

#Module to get the date of each document and put it in the conversation heading
module Dates
  @doc_dates_hash = {}
  for legis in 4..8  
    datesDir = "#{DATES_FILES_SUBDIR}#{legis}"
    #CSV.foreach("../dates/legislatura4/dates.csv") do |row|
    CSV.foreach("#{datesDir}/dates.csv") do |row|
      doc, date = row
      @doc_dates_hash[doc] = date
    end
  end
  
  def self.date(doc)
    @doc_dates_hash[doc]
  end

end

def markup_line (line, line_number) 
  #Page mark-up line
  if line.match(/(^\[PAGE [0-9]+\])|(^\[SECOND_COLUMN\])|(^SUMARIO)|(^[0-9]+(\s)*$)/) 
    #puts "Línea #{line_number+1}: mark-up line"
    return true
  else
    return false
  end
end

def checkConversation (line, line_number, doc)
  #RegExp to determine if the line contains a conversation Heading
  if line.match(/^(\s)*[OA] señor(a)? (([A-ZÁÉÍÓÚÜ]{2,})|((president[ea]|candidat[oa]|conselleir[oa]) .* [A-ZÁÉÍÓÚ]{2,} .*\):))/)
    #Check if we find a colon, sometimes a typo is found and instead of a colon a period or a semicolon is used
    pos = line.index(/(:|[A-ZÁÉÍÓÚ\)];|[A-ZÁÉÍÓÚ\)]\.)/)
    if pos
      return true
    else
      $log_file.puts("#{doc}/Linea #{line_number+1} detected possible heading but no good termination (Review)\n\n#{line}")
      return false
    end
  end
end

def writeHeading (line, doc ,legis) 
  #Get the date of the document from the previously
  #obtained csv (serializeMultipleColumn.rb)
  
  dateDoc = Dates.date("#{doc.gsub(/_restored\.txt/, '')}")
  pos = line.index(/(:|[A-ZÁÉÍÓÚ\)];|[A-ZÁÉÍÓÚ\)]\.)/)
  $output_file.write("[#{legis};#{dateDoc};#{line[0,pos]}]\n")
  $output_file.write("#{line[pos+1,line.length]}")
end

$log_file = File.open("#{LOG_SUBDIR}/extractConversations.log", 'w')
for legis in 4..8
  datesDir = "#{DATES_FILES_SUBDIR}#{legis}"
  inputDir = "#{INPUT_FILES_SUBDIR}#{legis}"
  outputDir = "#{OUTPUT_FILES_SUBDIR}#{legis}"
  FileUtils.makedirs(outputDir)
  
  Dir.entries(inputDir).select{|f| f.match(/.*\.txt/)}.each do |doc|
  #Dir.entries(inputDir).select{|f| f.match(/D40011_restored.txt/)}.each do |doc|
    $output_file = File.open("#{outputDir}/#{doc.gsub(/_restored\.txt/, '')}_conversations.txt", 'w')
    input_file = File.open("#{inputDir}/#{doc}").readlines[0..-1]
    
    tot_num_conv = 0
    #first run through the text in order to extract general info needed for the second run
    input_file.each_with_index do |line, line_number|
      tot_num_conv +=1 if checkConversation(line, line_number, doc)
    end
    
    #second run through the text to extract the conversations
    num_conv = 0
    inside_conversations=false
    input_file.each_with_index do |line, line_number|
      #output the conversation heading
      if (checkConversation(line, line_number, doc))
        inside_conversations = true if (num_conv == 0)
        num_conv +=1
        writeHeading(line,doc,legis)
        next
      end
      
      if (inside_conversations)
        #TODO: Clean up this conversation end detection....some better method??
        if (num_conv == tot_num_conv)
          if line.match(/([lL]ev[aá]ntase|[sS]usp[eé]ndese|[rR]emata) a sesi[oó]n/)
            inside_conversations = false
            #We manually write the last line to the output file since it should be included
            $output_file.write("#{line}")  
          end
          if line.match(/^(RELACI[OÓ]N DE DEPUTAD[OA]S)|(DIARIO DE SESI[OÓ]NS)|(Hórreo, 63)/) 
            inside_conversations = false
          end
        end
      end 
      
      #write output if we are inside a conversation and the line is not for markup
      if (inside_conversations)
        #If the line is a markup line just skip it else write to output file
        if (markup_line(line, line_number)) 
          next
        else
          $output_file.write("#{line}")  
        end
      end 
    end # each line
    if (inside_conversations)
      $log_file.puts("#{doc}: The end of the conversations section has not been detected")
    end
  end # each doc
  puts "Legislative period #{legis}: processed"
end #for legis