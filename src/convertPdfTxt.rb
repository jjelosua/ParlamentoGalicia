# encoding: utf-8

# Extract all text from a single PDF
require 'fileutils'

PDF_DOCS_SUBDIR = '../pdfs/legislatura'
TXT_DOCS_SUBDIR = '../txt/legislatura'
DOCPATH = File.expand_path(File.dirname(__FILE__)) + "/pdfs/legislatura"

for legis in 1..8
  pdfdir = "#{PDF_DOCS_SUBDIR}#{legis}"
  txtdir = "#{TXT_DOCS_SUBDIR}#{legis}"
  FileUtils.makedirs(txtdir)
  Dir.entries(pdfdir).select{|f| f.match(/.*.pdf/)}.each do |doc|
    txt_f_name = "#{txtdir}/#{doc.gsub(/\.pdf/i, '')}_layout.txt"
    `pdftotext -enc UTF-8 -layout "#{pdfdir}/#{doc}" "#{txt_f_name}"`
	end 
  puts "Procesados los documentos de la legislatura #{legis}"
end