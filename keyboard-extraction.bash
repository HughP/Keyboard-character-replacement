#!/bin/bash
################################################################################
# XML Reading .keylayout files
################################################################################

#We have already found and counted the Keyboard layout files. We have already 
#found which languages they belong to.

#Assuming that we are working with .keylayout files:...
#We need to now copy the file and replace the following characters with new 
#characters Because the XML read function on CSVfix and Starlet both choke 
#on the encoded control characters. Starlet does better and only chokes 
#on U+0008 which is the character for back-space.

#The solution I have imagined is that all control characters can be changed to 
#the Unicode character which is a glyph to represent the character. However, to 
#do this I need to be able to read the input text. For example I need to change
# '&#x0001' to '␁'. 

#Find keyboad layout files
LIST_OF_KEYBOARDS=$(find * -maxdepth 0 -iname "*.keylayout")

#Make a copy of the keyboard layout file

for i in $LIST_OF_KEYBOARDS; do
	cp "${i}" "${i%%.*}"-copy.xml
done

LIST_OF_COPIED_KEYBOARDS=$(find * -maxdepth 0 -iname "*-copy.xml")

sed -i.bak -f standard-replacements.sed $LIST_OF_COPIED_KEYBOARDS

rm -rf *.bak
#Use csvfix to read the newly edited '*-copy.xml' file and create comma 
#spliced file from which joins can be based

for i in $LIST_OF_COPIED_KEYBOARDS; do
	#Get the title of the keyboard
	csvfix from_xml -re 'keyboard' -nc ${i} | csvfix exclude -f 1,2,4 > ${i%%.xml}-language.txt
	#Get the states of the keyboard
	csvfix from_xml -re 'keyboard@modifierMap@keyMapSelect' -np ${i} | csvfix exclude -f 8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27 > ${i%%.xml}-states.csv
	#Get the keys in the keyboard.
	csvfix from_xml -re 'keyMapSet@keyMap@key' -nc ${i} | csvfix exclude -f 1,2,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27 > ${i%%.xml}-keys.csv
	#Lets combine the two files so that we know the names of the buttons to change the states.
	csvfix join -f 2:1  ${i%%.xml}-keys.csv ${i%%.xml}-states.csv | csvfix order -f 1,2,5,3,4 > ${i%%.xml}-combined.csv
	#Lets get a list of the characters used by the keyboard.
	cat "${i%%.xml}"-combined.csv | csvfix echo -smq | cut -d',' -f5 > ${i%%.xml}-characters-in-keyboard.csv
	#Lets use UnicodeCount to add the Unicode numbers to our table too.
	cat "${i%%.xml}"-characters-in-keyboard.csv | uniq > UNICODE_COUNT.txt
	UnicodeCCount UNICODE_COUNT.txt > ${i%%.xml}-unicode.tab
	csvfix read_dsv -s '\t' -f 2,3 ${i%%.xml}-unicode.tab > ${i%%.xml}-unicode.csv 
	csvfix join -f 5:2 ${i%%.xml}-combined.csv ${i%%.xml}-unicode.csv > ${i%%.xml}-combined-with-unicode.csv
	#Lets clean up some of these files.
	rm -rf ${i%%.xml}-states.csv
	rm -rf ${i%%.xml}-keys.csv
	rm -rf ${i%%.xml}-characters-in-keyboard.csv
	rm -rf UNICODE_COUNT.txt
	rm -rf ${i%%.xml}-unicode.tab
	rm -rf ${i%%.xml}-unicode.csv
	rm -rf ${i%%.xml}-combined.csv
	rm -rf 
done
	