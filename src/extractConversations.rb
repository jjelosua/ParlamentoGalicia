# encoding: utf-8

# Extract all text from a single PDF
require 'fileutils'

LOG_SUBDIR = '../logs'
TXT_DOCS_SUBDIR = '../serialized_txt/legislatura'
CONV_TXT_DOCS_SUBDIR = '../conversations/legislatura'

def markup_line (line, line_number) 
  if line.match(/^\[PÁGINA/)
    #puts "Línea #{line_number+1}: página nueva"
    return true
  elsif line.match(/^\[SEGUNDA_COLUMNA\]/)
    #puts "Línea #{line_number+1}: segunda columna" 
    return true
  elsif line.match(/(^SUMARIO)|(^[0-9]+$)/)
    #puts "Línea #{line_number+1}: encontrado sumario o un número"
    return true
  else
    return false
  end
end

def writeHeading (firstLine, secondLine, file, num_conv, tot_num_conv, dateDoc ,legis) 
  if (num_conv != 1)
    file.write("\n\n")
  end
  pos = firstLine.index(':')
  if (pos)
    file.write("[#{legis};#{num_conv};#{dateDoc};#{firstLine[0,pos]}]\n")
    file.write("\n\n#{firstLine[pos+1,firstLine.length]}")
    return false
  else
    pos = secondLine.index(':')
    file.write("[#{legis};#{num_conv};#{dateDoc};#{firstLine.strip} #{secondLine[0,pos]}]\n")
    file.write("\n\n#{secondLine[pos+1,secondLine.length]}")
    return true
  end  
end
log_file = File.open("#{LOG_SUBDIR}/extractConversations.log", 'w')
for legis in 4..8
  txtdir = "#{TXT_DOCS_SUBDIR}#{legis}"
  ptxtdir = "#{CONV_TXT_DOCS_SUBDIR}#{legis}"
  FileUtils.makedirs(ptxtdir)
  Dir.entries(txtdir).select{|f| f.match(/.*.txt/)}.each do |doc|
  #Dir.entries(txtdir).select{|f| f.match(/D40011_serialized.txt/)}.each do |doc|
    conv_file = File.open("#{ptxtdir}/#{doc.gsub(/_serialized\.txt/i, '')}_conversations.txt", 'w')
    orig_text = File.open("#{txtdir}/#{doc}").readlines[0..-1]
    #first run through the text in order to extract general info needed for the second run
    pages_format = []
    two_column_page = 0
    tot_num_conv = 0
    dateDoc = nil
    orig_text.each_with_index do |line, line_number|
      #extract the date from the first page
      if ((pages_format.length == 0) && (line.match(/^[0-9]{1,2} de .* de [0-9]{4}$/)))
        dateDoc = line.strip
        #puts "Fecha del documento: #{dateDoc}"
      end
      if (line.match(/\[SEGUNDA_COLUMNA\]/))
        two_column_page = 1
      end
      if (line.match(/\[PÁGINA [0-9]+\]/))
        pages_format.push(two_column_page)
        two_column_page = 0
      end
      #extract the number of conversations on the text
      if line.match(/(^O señor [A-Z]{1,})|(^A señora [A-Z]{1,})/)
        #puts "line #{line_number+1}: #{line}"
        if (line.index(':') || orig_text[line_number+1].index(':'))
          tot_num_conv +=1
        end
      end
    end
    #puts "Número de páginas: #{pages_format.length}"
    #puts "Número de conversaciones: #{tot_num_conv}"
    
    #second run through the text to extract the conversations
    num_conv = 0
    inside_conversations=false
    two_line_heading = false
    last_conv_new_page = false
    orig_text.each_with_index do |line, line_number|
      #extract the number of conversations on the text
      if line.match(/(^O señor [A-Z]{1,})|(^A señora [A-Z]{1,})/)
        #puts "line #{line_number+1}: #{line}"
        if (line.index(':') || orig_text[line_number+1].index(':'))
          inside_conversations = true if (num_conv == 0)
          num_conv +=1
          two_line_heading = writeHeading(line, orig_text[line_number+1],conv_file,num_conv,tot_num_conv,dateDoc,legis)
          next
        end
      end
      #If the heading takes two line skip the second line two an reset indicator
      if (two_line_heading)
        two_line_heading = false
        next
      end
      
      if (inside_conversations)
        #TODO: Clean up this detection....some better method??
        #We try to capture the end of the conversations via 2 alternative ways
        if (num_conv == tot_num_conv)
          if line.match(/([lL]ev[aá]ntase|[sS]usp[eé]ndese|[rR]emata) a sesi[oó]n/)
            inside_conversations = false
            #We manually write the last line to the output file
            conv_file.write("#{line}")  
          end
          if line.match(/^Eran as .* (minutos)? da (tarde|mañá|serán|noite)/)
            inside_conversations = false
          end
          if (line.match(/^\[PÁGINA [0-9]+\]$/))
            #log_file.puts("#{doc}: nueva página en la última conversación (revisar)")
            last_conv_new_page = true
          end
          if (last_conv_new_page) 
            if line.match(/^(RELACI[OÓ]N DE)|(DIARIO DE)|(Hórreo, 63)/) 
              #log_file.puts("#{doc}: página de RELACIÓN o DIARIO")
              inside_conversations = false
            end
            
          end
        end
      end 
      
      #write output if we are inside a conversation and the line is not for markup
      if (inside_conversations)
        #If the line is a markup line just skip it else write to output file
        if (markup_line(line, line_number)) 
          next
        else
          conv_file.write("#{line}")  
        end
      end 
    end # each line
    if (inside_conversations)
      log_file.puts("#{doc}: No se ha detectado el final de las conversaciones")
    end
  end # each doc
  puts "Procesados los documentos de la legislatura #{legis}"
end #for legis