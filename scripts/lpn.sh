#!/bin/bash
## This is the Parsing Process
## For Lists that barely need it

## Variables
source /etc/piholeparser/scriptvars/variables.var

####################
## File Lists     ##
####################

echo ""
printf "$green"   "Filtering Lists that barely need parsing."
echo ""
timestamp=$(echo `date`)
sudo echo "## LightParsing $timestamp" | sudo tee --append $RECENTRUN &>/dev/null

## Start File Loop
for f in $LIGHTPARSE
do

echo ""
printf "$blue"    "___________________________________________________________"
echo ""

## Process sources within file.lst
for source in `cat $f`;
do

## Set Variables (again, I guess)
source /etc/piholeparser/scriptvars/variables.var
BASEFILENAME=$(echo `basename $FNAME`)

printf "$green"    "Processing $BASEFILENAME list"
echo "" 
printf "$cyan"    "Downloading from"
printf "$cyan"    "$source"
echo "" 

####################
## Download Lists ##
####################

if [[ -z $UPCHECK ]]
then
printf "$yellow"    "Fetching List From Local File"
echo ""
sudo curl --silent -L $source >> $TEMPFILE
sudo cat $TEMPFILE >> $ORIGFILE
sudo rm $TEMPFILE
else 
SOURCEIPFETCH=`ping -c 1 $UPCHECK | gawk -F'[()]' '/PING/{print $2}'`
SOURCEIP=`echo $SOURCEIPFETCH`
printf "$yellow"    "Fetching List from $UPCHECK located at the IP of $SOURCEIP"
echo ""
sudo wget -q -O $TEMPFILE $source
sudo cat $TEMPFILE >> $ORIGFILE
sudo rm $TEMPFILE
fi

## Source completion
done

echo -e "\t`wc -l $ORIGFILE | cut -d " " -f 1` lines downloaded"
ORIGFILESIZE=$(stat -c%s "$ORIGFILE")
printf "$yellow"  "Size of $ORIGFILE = $ORIGFILESIZE bytes."
echo ""

if 
[ "$ORIGFILESIZE" -eq 0 ]
then
timestamp=$(echo `date`)
sudo echo "* $FNAME list was an empty file upon download $timestamp" | sudo tee --append $RECENTRUN &>/dev/null
else
:
fi

####################
## Create Mirrors ##
####################

echo ""
printf "$green"   "Attempting creation of mirror file"
echo ""

## Copy original, one for mirror, one for next step
sudo cp $ORIGFILE $MFILENAME

## Github has a 100mb limit, and empty files are useless
MFILESIZE=$(stat -c%s "$MFILENAME")
timestamp=$(echo `date`)
if 
[ "$MFILESIZE" -ge "$GITHUBLIMIT" ]
then
echo ""
printf "$red"     "Size of $MFILENAME = $MFILESIZE bytes."
printf "$red"     "Mirror File Too Large For Github. Deleting."
echo ""
sudo echo "* $BASEFILENAME list was too large to mirror on github. $MFILESIZE bytes $timestamp" | sudo tee --append $RECENTRUN &>/dev/null
sudo rm $MFILENAME
elif
[ "$MFILESIZE" -eq 0 ]
then
echo ""
printf "$red"     "Size of $MFILENAME = $MFILESIZE bytes. Deleting."
echo ""
sudo echo "* $BASEFILENAME list was an empty file $timestamp" | sudo tee --append $RECENTRUN &>/dev/null
sudo rm $MFILENAME
else
echo ""
printf "$yellow"     "Size of $MFILENAME = $MFILESIZE bytes."
printf "$yellow"  "Creating Mirror of Unparsed File."
echo ""
sudo mv $MFILENAME /etc/piholeparser/mirroredlists/
sudo rename "s/.mirror.txt/.txt/" /etc/piholeparser/mirroredlists/*.txt
fi

####################
## Pre-Processing ##
####################

## Copy for Pre-Processing
sudo mv $ORIGFILE $PRE

## Domain Requirements,, a period and a letter
PARSECOMMENT="Checking for FQDN Requirements."
printf "$yellow"  "$PARSECOMMENT ..."
sed '/[a-z]/!d; /[.]/!d' < $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE
echo ""

## Comments #'s and !'s, also empty lines
PARSECOMMENT="Removing Commented Lines."
printf "$yellow"  "$PARSECOMMENT ..."
sed '/^\s*#/d; s/[#]/\'$'\n/g; /[#]/d; /[!]/d; /^$/d' < $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE
echo ""

## Invalid Characters
PARSECOMMENT="Removing Invalid FQDN characters."
printf "$yellow"  "$PARSECOMMENT ..."
sed '/[/]/d; /[*]/d; /[#]/d; /[!]/d' < $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE
echo ""

## Periods at begining and end of lines
PARSECOMMENT="Removing Lines With a Period at the Start or End."
printf "$yellow"  "$PARSECOMMENT ..."
sed '/^[.],/d; /^[.]/d; /[.]$/d' < $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE
echo ""

## Add and remove Spaces
PARSECOMMENT="Replacing Spaces with NewLines, then Removing Empty Lines."
printf "$yellow"  "$PARSECOMMENT ..."
sed 's/\s\+/\n/g; /^$/d' < $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE
echo ""

## Remove IP addresses
PARSECOMMENT="Removing IP Addresses"
printf "$yellow"  "$PARSECOMMENT ..."
sed 's/^PRIMARY[ \t]*//; s/^localhost[ \t]*//; s/blockeddomain.hosts[ \t]*//;' < $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE
echo ""

sudo sed 's/^0.0.0.0[ \t]*//' $PRE > $POST
sudo rm $PRE
sudo mv $POST $PRE
sudo sed 's/^127.0.0.1[ \t]*//' $PRE > $POST
sudo rm $PRE
sudo mv $POST $PRE
sudo sed 's/^::1[ \t]*//' $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

## Remove lines without letters
echo ""
PARSECOMMENT="removing lines without letters"
printf "$yellow"  "$PARSECOMMENT ..."
sudo sed '/[a-z]/!d' < $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

## delete lines without a period
echo ""
PARSECOMMENT="removing lines without a period"
printf "$yellow"  "$PARSECOMMENT ..."
sudo sed '/[.]/!d' $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

## delete lines that start with a period
echo ""
PARSECOMMENT="removing lines that start with a period"
printf "$yellow"  "$PARSECOMMENT ..."
#sed '/^[.],/d' $PRE > $POST
sed '/^[.]/d' $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

## delete lines that end with a period
echo ""
PARSECOMMENT="removing lines that end with a period"
printf "$yellow"  "$PARSECOMMENT ..."
sed '/[.]$/d' $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

## Duplicate Removal
echo ""
PARSECOMMENT="removing duplicates"
printf "$yellow"  "$PARSECOMMENT ..."
sort -u $PRE > $POST
sudo rm $PRE
sudo mv $POST $PRE
sudo gawk '{if (++dup[$0] == 1) print $0;}' $PRE > $POST
sudo rm $PRE
echo -e "\t`wc -l $POST | cut -d " " -f 1` lines after $PARSECOMMENT"
sudo mv $POST $PRE

## Done with sifting
sudo mv $PRE $PFILENAME

####################
## Complete Lists ##
#################### 

echo ""
printf "$green"   "Attempting Creation of Parsed List."
echo ""

## Github has a 100mb limit, and empty files are useless
PFILESIZE=$(stat -c%s "$PFILENAME")
timestamp=$(echo `date`)
if
[ "$PFILESIZE" -ge "$GITHUBLIMIT" ]
then
echo ""
printf "$red"     "Size of $PFILENAME = $PFILESIZE bytes."
printf "$red"     "Parsed File Too Large For Github. Deleting."
echo ""
sudo echo "* Parsed $BASEFILENAME list too large for github. $PFILESIZE bytes $timestamp" | sudo tee --append $RECENTRUN &>/dev/null
sudo rm $PFILENAME
elif
[ "$PFILESIZE" -eq 0 ]
then
echo ""
printf "$red"     "Size of $PFILENAME = $PFILESIZE bytes. Deleting."
echo ""
sudo echo "* Parsed $BASEFILENAME list was an empty file $timestamp" | sudo tee --append $RECENTRUN &>/dev/null
sudo rm $PFILENAME
else
echo ""
printf "$yellow"  "Size of $PFILENAME = $PFILESIZE bytes."
printf "$yellow"  "File will be moved to the parsed directory."
echo ""
sudo mv $PFILENAME /etc/piholeparser/parsed/
sudo rename "s/.parsed.txt/.txt/" /etc/piholeparser/parsed/*.txt
fi

printf "$magenta" "___________________________________________________________"
echo ""

## End File Loop
done
sudo echo "" | sudo tee --append $RECENTRUN &>/dev/null
