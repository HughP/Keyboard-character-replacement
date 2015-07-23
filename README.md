# Keyboard-character-replacement
Small code for making .keylayout files readable and convertible into corpus text filters

##Scope and reason
This code is an independent section of code used in a larger task of keyboard analysis.

The goal is to use querry .keylayout files (the default keyboard layout file on OS X) for two puropeses:
  1. to find out which characters a keyboard is capable of creating
  2. to find out which characters in a corpus are not created by a given keyboard and to what frequency must language uses find a different text input method.

##Lead-in
Assuming that we are working with .keylayout files (which are XML files):...

We need to copy the file and in the coppied file, replace certain characters with new characters. The reason for this is that the XML read function on CSVfix and Starlet both choke on the encoded control characters. (These characters were not enabled in XML until something like version 1.1) Overall, Starlet does better and only chokes on U+0008 which is the character for back-space. But still there are these issues.

The solution I have imagined is that all control characters can be changed to the Unicode character which is a glyph to represent the character. However, to do this I need to be able to read the input text as strings. For example I need to change '`&#x0001;`' to '`␁`'. 

A bash, `for` loop with an embeded `while read -r` might do the trick. I hope to used `sed` with a `/pattern/replacement/` syntax from a list of common characters which are expressed as strings. 
