# encoding: utf-8
require 'fileutils'

LOG_SUBDIR = '../logs'
INPUT_FILES_SUBDIR = '../txt/legislatura'
OUTPUT_FILES_SUBDIR = '../serialized_txt/legislatura'
DATES_FILES_SUBDIR = '../dates/legislatura'
FileUtils.makedirs(LOG_SUBDIR)

$log_file = File.open("#{LOG_SUBDIR}/serializeMultipleColumn.log", 'w')
#Loop through all the available legistative periods 
for legis in 4..8
  inputDir = "#{INPUT_FILES_SUBDIR}#{legis}"
  outputDir = "#{OUTPUT_FILES_SUBDIR}#{legis}"
  FileUtils.makedirs(outputDir)
  datesDir = "#{DATES_FILES_SUBDIR}#{legis}"
  FileUtils.makedirs(datesDir)
  dates_file = File.open("#{datesDir}/dates.csv", 'w')
  Dir.entries(inputDir).select{|f| f.match(/.*\.txt/)}.each do |doc|
    output_file = File.open("#{outputDir}/#{doc.gsub(/_layout\.txt/, '')}_serialized.txt", 'w')
    input_file = File.open("#{inputDir}/#{doc}").readlines[0..-1]
    
    new_page = true
    page_number = 0
    new_page_line = 0
    two_column_page = false
    second_column_lines_list = []
    input_file.each_with_index do |line, line_number|
      #Skip the first two lines after each new page
      if (new_page && line_number < new_page_line+2) 
        next
      end 
      
      #Write the date of the session to a auxiliary date_file. Only search on the first page
      if (page_number == 0)
        #get the date from the first line of the document
        line.strip.match(/([0-9]{1,2} de [A-Za-zÁÉÍÓÚÑáéíóúñ]+ de [0-9]{4})/) {|m| dates_file.write("#{doc.gsub(/_layout\.txt/, '')},#{m[0]}\n")}
      end
      
      #If we are reading a new_page marker update the indicators
      #empty the second serialization part buffer if it exists
      #and go to the next iteration
      if (line.match(/^\f/))
        #puts "new page detected"
        #If we have passed through a two column page then we need to write the second column buffer
        #to the output before starting with a new page.
        if (two_column_page)
          #output_file.write("\n[SECOND_COLUMN]\n")
          second_column_lines_list.each do |aux_line|
          output_file.write("#{aux_line}\n")
          end
          second_column_lines_list.clear
        end
        page_number += 1;
        #output_file.write("\n[PAGE #{page_number}]\n")
        new_page = true
        new_page_line = line_number
        two_column_page = false
        next
      end
      
      #Get the columns in this line
      columns = line.strip.split(/ {2,}/).map{|col| col.strip}
      
      if (columns.length > 0)
        #Heading of the page on the document we can skip this lines
        if (columns.length > 2) && columns[0].match(/^Número/)
          next
        end
        
        #We need to determine which of those columns correspond 
        #to the first part of the serialization
        #and which correspond to the second part
        processed_excep = false
        columns.each_with_index do |column, col_index|
          if (line.index(column) >= 49)
            output_file.write("#{columns[0..col_index-1].join(" ")}\n") if (col_index > 0)
            two_column_page = true
            second_column_lines_list.push(columns[col_index..columns.length].join(" "))
            processed_excep = true
            break
          end
        end
        next if (processed_excep)   
        #If we have not detected parts of the line in the second part of the serialization
        # join together the columns and put them in the first part.
        output_file.write("#{columns.join(" ")}\n")
        if (columns.length > 2)
          $log_file.puts("Line #{doc}/#{line_number+1}: more 2 columns first part serialization. #{columns.join(" ")}\n")
        end
      else
        output_file.write(line)
      end
    end # each line
  end # each doc
  puts "Legislative period #{legis}: processed"
end #for legis