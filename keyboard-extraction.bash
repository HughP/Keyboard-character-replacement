#!/bin/bash
##########################
# XML Reading .keylayout files
##########################

#We have already found and counted the Keyboard layout files. We have already found which languages they belong to.

#Assuming that we are working with .keylayout files:...
#We need to now copy the file and replace the following characters with new characters Because the XML read function on CSVfix and Starlet both choke on the encoded control characters. Starlet does better and only chokes on U+0008 which is the character for back-space.

#The solution I have imagined is that all control characters can be changed to the Unicode character which is a glyph to represent the character. However,to do this I need to be able to read the input text. For example I need to change '&#x0001' to '␁'. 

#Find keyboad layout files
find * -maxdepth 0 -iname "*.keylayout" > list-of-keyboards.txt

#Make a copy of the keyboard layout file

for i in $(cat list-of-keyboards.txt);do
	cp "${i}" "${i%%.*}"-copy.xml
done

find * -maxdepth 0 -iname "*-copy.xml" > list-of-copied-keyboards.txt

#Save the old IFS separator
old_IFS=$IFS # save the field separator 

#New IFS set it to ',' to match the format in the standard-repalcements.txt file. The 'while read -r' line of code will need to access the fields.
IFS=$','  # new field separator

#load the file of standard replacements to perform on the newly created .xml files

s=$(cat standard-replacements.txt)

#For each keyboard file
for i in $(cat list-of-copied-keyboards.txt); do
#cycle through each line in the standard replacements file.
	for j in $s; do 
	#set the first field to the first variable as the thing to find, the second field as the second variable as the thing to replace. following instructions from here: http://pubs.opengroup.org/onlinepubs/7908799/xcu/read.html
		while read -r t q; do
		#Use sed to actually do the repacement. Following the example from number 4 here: http://unix.stackexchange.com/questions/112023/how-can-i-replace-a-string-in-a-files
		#I think the final variable "${i}" at the end of the line tells sed to do a in place replacement on the file at the location "${i}". There is also something about sed needing '' after -i on OS X: http://unix.stackexchange.com/questions/112023/how-can-i-replace-a-string-in-a-files#comment293042_112024
			sed -i -e "s/$t/$q/g" "${i}"
		done 
	done
done
	
#Return the old IFS seperator 
IFS=$old_IFS # restore default field separator 


#Use csvfix to read the newly edited '*-copy.xml' file and create comma spliced file from which joins can be based
