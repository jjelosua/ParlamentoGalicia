# encoding: utf-8

# Extract all text from a single PDF
require 'fileutils'

TXT_DOCS_SUBDIR = '../txt/legislatura'
PARSE_TXT_DOCS_SUBDIR = '../serialized_txt/legislatura'

for legis in 1..8
  txtdir = "#{TXT_DOCS_SUBDIR}#{legis}"
  ptxtdir = "#{PARSE_TXT_DOCS_SUBDIR}#{legis}"
  FileUtils.makedirs(ptxtdir)
  Dir.entries(txtdir).select{|f| f.match(/.*.txt/)}.each do |doc|
    serialized_file = File.open("#{ptxtdir}/#{doc.gsub(/_layout\.txt/i, '')}_serialized.txt", 'w')
    orig_text = File.open("#{txtdir}/#{doc}").readlines[0..-1]
    new_page = true
    page_number = 0
    new_page_line = 0
    two_column_page = false
    second_column_lines_list = []
    orig_text.each_with_index do |line, line_number|
      #Skip the first three lines after the each new page
      if (new_page && line_number < new_page_line+3) 
        next
      end  
      
      #If we are reading a new_page marker update the indicators and go to the next iteration
      if (line.strip == "(NEW_PAGE)")
        #If we have passed through a two column page then we need to write the second column buffer
        #to the output before starting with a new page.
        if (two_column_page)
          serialized_file.write("\n[SEGUNDA_COLUMNA]\n")
          #puts "La lista de la segunda columna tiene #{second_column_lines_list.length} lineas"
          second_column_lines_list.each do |aux_line|
          serialized_file.write("#{aux_line}\n")
          end
          second_column_lines_list.clear
        end
        page_number += 1;
        serialized_file.write("\n[PÁGINA #{page_number}]\n")
        new_page = true
        new_page_line = line_number
        two_column_page = false
        next
      end
      
      #Get the columns in this line
      columns = line.strip.split(/ {2,}/).map{|col| col.strip}
      
      #If the page is a two column page:
      # -If we have two columns on the line write the first column to the output
      #  and save the second column in a buffer until we have reached the new_page mark
      # -If we have only one column and starts in an index less than 50 then we assume 
      #  that this is a first column line and we write to the output
      # -If we have only one column and starts in an index more than 50 chars away from the 
      #  begining of the line then we assume it is a second column line and we save the line 
      #  to the buffer writing a newline to the output to maintain the structure.
      if (columns.length == 2)
        serialized_file.write("#{columns[0]}\n")
        second_column_lines_list.push(columns[1])
        two_column_page = true
      elsif (columns.length == 1)
        if (line.index(columns[0]) >= 49)
          two_column_page = true
          second_column_lines_list.push(columns[0])
        else
          serialized_file.write("#{columns[0]}\n")
        end
      elsif (columns.length > 2)
        next
      else
        serialized_file.write("#{line.strip}\n")
      end
    end # each line
  end # each doc
  puts "Procesados los documentos de la legislatura #{legis}"
end #for legis