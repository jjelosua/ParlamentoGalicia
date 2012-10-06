# encoding: utf-8

# Extract all text from a single PDF
require 'fileutils'

LOG_SUBDIR = '../logs'
CONV_DOCS_SUBDIR = '../conversations/legislatura'
CLEAN_DOCS_SUBDIR = '../cleanConv/legislatura'

log_file = File.open("#{LOG_SUBDIR}/cleanUpConversations.log", 'w')
for legis in 4..8
  txtdir = "#{CONV_DOCS_SUBDIR}#{legis}"
  ptxtdir = "#{CLEAN_DOCS_SUBDIR}#{legis}"
  FileUtils.makedirs(ptxtdir)
  Dir.entries(txtdir).select{|f| f.match(/.*.txt/)}.each do |doc|
  #Dir.entries(txtdir).select{|f| f.match(/D40015_conversations.txt/)}.each do |doc|
    clean_file = File.open("#{ptxtdir}/#{doc.gsub(/_conversations\.txt/i, '')}_cleanConv.txt", 'w')
    orig_text = File.open("#{txtdir}/#{doc}").readlines[0..-1]
    #puts "procesando el documento: #{doc}"
    #run through the conversations to clean them up
    orig_text.each_with_index do |line, line_number|
      #Clean up multiple empty lines together
      if ((line.match(/^\n$/)) && line_number+1 < orig_text.length &&orig_text[line_number+1].match(/^\n$/))
        #puts "Línea #{line_number+1}: Está en blanco y la siguiente también"
        next
      end
      
      #If we have a . inside a line split into two lines on the output
      if (line.match(/.+\. [A-Z]{1}[a-z]{1,}.+/))
        #puts "Línea #{line_number+1}: Contiene un punto en medio"
        pos = line.index('.',1)
        clean_file.write("#{line[0,pos+1]}\n")
        aux = line[pos+2,line.length]
      else
        aux = line
      end
      
      #If the lines finishes in - get rid of that and the newline and continue on output
      if (aux.match(/-\n$/))
        #puts "Línea #{line_number+1}: Acaba en guión"
        clean_file.write(aux[0,aux.length-2])
      elsif (aux.match(/(\.|:)\n$/))
        #puts "Línea #{line_number+1}: Acaba en punto o dos puntos"
        clean_file.write(aux)
      elsif (aux.match(/]$/))
        clean_file.write("#{aux}\n")
      elsif (aux.match(/.\n$/))
        clean_file.write("#{aux.strip} ")
      else 
        if ((line_number+1 < orig_text.length) && (orig_text[line_number+1].match(/^\[/)))
          clean_file.write("\n")
        elsif (aux.match(/^\n$/))
          #Skip this empty line since it comes from the two column bad alligment
        else
          log_file.puts("#{doc}: No tenemos controlada este caso. Línea #{line_number+1}")
        end
      end
    end # each line
  end # each doc
  puts "Procesados los documentos de la legislatura #{legis}"
end #for legis