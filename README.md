Parlamento de Galicia - Diario de sesiones
==========================================

Description
-----------

*ParlamentoGalicia* is a free software ruby application used to scrape the information from the [Galician Parlament sessions][1]

In order to extract the information the following steps are needed executed in the same order.

1.- execute scrapePdfs 
(downloads the pdf files from the Galician parlament web site to a local folder ../pdfs/)
2.- execute convertPdfTxt 
(converts the pdf files to text imitating the layout of the original file output folder ../txt **)
3.- execute serializeMultipleColumn 
(serialize the two column pages of the text file obtained in the previous step ../serialized_txt)
4.- execute restoreLines
(restore lines to the full size without wraping ../restored_txt)
5.- execute extractConversations 
(loop through the text files from previous step and extract the conversations found ../conversations)
6.- execute cleanUpConversations 
(clean up the exceptions found on the files from the previous step ../cleanConv)
7.- execute crossCheckConversations 
(makes a log file with possible uncaptured conversations  ../logs (Review this manually to achieve 100% accuracy))


**Note: Only the text selectable part of the pdfs will be extracted, so older sessions that are scanned images will be ignored.

**Note: A ../logs folder is created showing warnings or info messages about each step of the process.
This process can be slow and there is no output on screen just on the ../logs folder...be patient my friend!!

Requirements
------------

*You need the have a running version of ruby in your computer (only tested on ruby 1.9.3p194 but it should work in older versions, if it doesn't please report a bug) 

For running the second step of this scraping application:
* You need to have installed in your OS the open source command-line tool [pdftotext][2]

Reporting bugs
--------------

Please use the issue [reporting tool in github][4]

License
-------

*ParlamentoGalicia* is released under the terms of the [Apache License version 2.0][3].

Please read the ``LICENSE`` file for details.

Authors
-------

Please see ``AUTHORS`` file for more information about the authors.



[1]: http://www.parlamentodegalicia.es/sitios/web/ContenidoGal/Procuras/Boletins.aspx
[2]: http://www.foolabs.com/xpdf/home.html
[3]: http://www.apache.org/licenses/
[4]: https://github.com/jjelosua/espanaenllamas.es/issues
