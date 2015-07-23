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