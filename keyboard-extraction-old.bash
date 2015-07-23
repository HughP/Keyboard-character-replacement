#!/bin/bash
##########################
# XML Reading .keylayout files
##########################

#We have already found and counted the Keyboard layout files. We have already found which languages they belong to.

#Assuming that we are working with .keylayout files:...
#We need to now copy the file and replace the following characters with new characters Because the XML read function on CSVfix and Starlet both choke on the encoded control characters. Starlet does better and only chokes on U+0008 which is the character for back-space.

#The solution I have imagined is that all control characters can be changed to the Unicode character which is a glyph to represent the character. However,to do this I need to be able to read the input text. For example I need to change '&#x0001' to '␁'. 

#Find keyboad layout files
LIST_OF_KEYBOARDS=$(find * -maxdepth 0 -iname "*.keylayout")

#Make a copy of the keyboard layout file

for i in $LIST_OF_KEYBOARDS;do
	cp "${i}" "${i%%.*}"-copy.xml
done

LIST_OF_COPPIED_KEYBOARDS=$(find * -maxdepth 0 -iname "*-copy.xml")

#Save the old IFS separator
OLD_IFS=$IFS # save the field separator 

#New IFS set it to ',' to match the format in the standard-repalcements.txt file. The 'while read -r' line of code will need to access the fields.
#IFS=$','  # new field separator

#load the file of standard replacements to perform on the newly created .xml files

#s=$(cat standard-replacements.txt)

#For each keyboard file
#for i in $(cat list-of-copied-keyboards.txt); do
#cycle through each line in the standard replacements file.
#	for j in $s; do 
	#set the first field to the first variable as the thing to find, the second field as the second variable as the thing to replace. following instructions from here: http://pubs.opengroup.org/onlinepubs/7908799/xcu/read.html
#		while read -r t q; do
		#Use sed to actually do the repacement. Following the example from number 4 here: http://unix.stackexchange.com/questions/112023/how-can-i-replace-a-string-in-a-files
		#I think the final variable "${i}" at the end of the line tells sed to do a in place replacement on the file at the location "${i}". There is also something about sed needing '' after -i on OS X: http://unix.stackexchange.com/questions/112023/how-can-i-replace-a-string-in-a-files#comment293042_112024
		sed -i.bak -f standard-replacements.sed $(cat $LIST_OF_KEYBOARDS)
#			sed -f standard-replacements.sed
#			sed -i.bak -e "s/$t/$q/g" "${i}"
#		done 
#	done
#done
	
#Return the old IFS seperator 
#IFS=$OLD_IFS # restore default field separator 


It's hard to tell you what's wrong if you don't tell me what the error
message or problem is!

> true, my apologies.

I've looked at the code and I don't see anything obviously wrong. The
info about sed -i on Mac is correct. You have to supply a parameter
(backup suffix) or it will use the -e as a backup suffix. I don't think
this will stop it from working, but the behaviour will be different on
Mac and Linux. I recommend using -i.bak (no space) to ensure consistent
behaviour across platforms.

Instead of using read, you could put the sed replacement commands into
standard-replacements.txt(renaming it to standard-replacements.sed) and
execute it directly in sed using sed -f standard-replacements.sed. You
can even make the file executable and put a shebang of #!/bin/sed -f at
the top and then you can run it like a shell command! You wouldn't have
to monkey with IFS, then, and in fact you could remove both for loops:

sed -i.bak -f standard-replacements.sed $(cat list-of-keyboards)

Another idea for improvement: instead of putting lists of filenames into
temporary files, you could put them into shell variables instead:

list-of-keyboards=$(find * -maxdepth 0 -iname "*.keylayout")

for i in $list-of-keyboards; do

> Yes totally. I see what you are saying...


Finally, IFS=$',' looks odd. Why not just IFS=',' ? However, the extra $
doesn't seem to change the behaviour.

> The results of copying from different sources, and not knowing exactly what is 'propper'...

A couple other points, too:

Your long comment lines are hard to read in the github view.
> I'll fix that.
I recommend hard-wrapping all source files to have lines no longer than 80 or 100
characters (a common convention in the industry).

> Thank you for this pointer. I wish there was an easy way to wrap lines before save. Most of my long lines are comments. Obviosuly, when I share code I want it to be easily readable by others. I have a really long lines in part due to a big screen. If I am not mistaken the 80-100 practice is a carry over from older days with smaller monitors. My programming window is also at least 150 char wide. To boot, I then make my active terminal window as wide. Is there an automated way to switch between these constraints? I like bigger/longer for readability on my end, but I really do value conforming to good practice.

It's a matter of personal taste/preference, but I like to use
all-uppercase for variable names in bash, to make them stand out from
non-variable text. (This is a common, but not universal, convention in
bash programming.) The reason for making them stand out is that the
difference between rm -rf $mydir and rm -rf mydir is hard to spot! :-)

> Right. Agreed

#Use csvfix to read the newly edited '*-copy.xml' file and create comma spliced file from which joins can be based