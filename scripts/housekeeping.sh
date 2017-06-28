#!/bin/bash
## This should do some initial housekeeping for the script

## Variables
source /etc/piholeparser/scripts/scriptvars/staticvariables.var

## Recreate Tempvars
CHECKME=$TEMPVARS
if
ls $CHECKME &> /dev/null;
then
rm $CHECKME
echo "## Vars that we don't keep" | tee --append $TEMPVARS &>/dev/null
else
echo "## Vars that we don't keep" | tee --append $TEMPVARS &>/dev/null
fi

######################
## Set Start Time   ##
######################

SCRIPTTEXT="Setting Start Time Variable."
timestamp=$(echo `date`)
printf "$lightblue"    "___________________________________________________________"
echo ""
printf "$cyan"   "$SCRIPTTEXT $timestamp"
echo ""
echo "## $SCRIPTTEXT $timestamp" | tee --append $RECENTRUN &>/dev/null
bash $DELETETEMPFILE
STARTTIME="Script Started At $timestamp"
STARTTIMESTAMP=$(date +"%s")
echo "STARTTIME="Script Started At $timestamp"" | tee --append $TEMPVARS &>/dev/null
echo "STARTTIMESTAMP=$(date +"%s")" | tee --append $TEMPVARS &>/dev/null
bash $DELETETEMPFILE
echo ""
echo "" | tee --append $RECENTRUN &>/dev/null
printf "$orange" "___________________________________________________________"
echo ""

######################
## Recent Run Log   ##
######################

SCRIPTTEXT="Creating Main Recent Run Log."
timestamp=$(echo `date`)
printf "$lightblue"    "___________________________________________________________"
echo ""
printf "$cyan"   "$SCRIPTTEXT $timestamp"
echo ""
echo "## $SCRIPTTEXT $timestamp" | tee --append $RECENTRUN &>/dev/null
bash $DELETETEMPFILE
if 
ls $RECENTRUNMAIN &> /dev/null; 
then
rm $RECENTRUNMAIN
echo "## $SCRIPTTEXT $timestamp" | tee --append $RECENTRUN &>/dev/null
echo "* Recent Run Log Removed and Recreated." | tee --append $RECENTRUN &>/dev/null
else
echo "## $SCRIPTTEXT $timestamp" | tee --append $RECENTRUN &>/dev/null
echo "* Recent Run Log Created." | tee --append $RECENTRUN &>/dev/null
fi
echo "* $STARTTIME" | tee --append $RECENTRUN &>/dev/null
bash $DELETETEMPFILE
echo ""
echo "" | tee --append $RECENTRUN &>/dev/null
printf "$orange" "___________________________________________________________"
echo ""

######################
## https-less lists ##
######################

SCRIPTTEXT="Identifying Lists Without https."
timestamp=$(echo `date`)
printf "$lightblue"    "___________________________________________________________"
echo ""
printf "$cyan"   "$SCRIPTTEXT $timestamp"
echo ""
echo "## $SCRIPTTEXT $timestamp" | tee --append $RECENTRUN &>/dev/null
bash $DELETETEMPFILE
if 
ls $NOHTTPSLISTS &> /dev/null; 
then
rm $NOHTTPSLISTS
echo "## $SCRIPTTEXT $timestamp" | tee --append $RECENTRUN &>/dev/null
else
echo "## $SCRIPTTEXT $timestamp" | tee --append $RECENTRUN &>/dev/null
fi
for f in $EVERYLISTFILEWILDCARD
do
for source in `cat $f`;
do
if
[[ $source != https* ]]
then
echo "* $BASEFILENAME" | tee --append $NOHTTPSLISTS &>/dev/null
fi
done
done
bash $DELETETEMPFILE
echo ""
echo "" | tee --append $RECENTRUN &>/dev/null
printf "$orange" "___________________________________________________________"
echo ""

#######################
## Parsed Not In Use ##
#######################

SCRIPTTEXT="Removing Parsed Lists No Longer Used."
timestamp=$(echo `date`)
printf "$lightblue"    "___________________________________________________________"
echo ""
printf "$cyan"   "$SCRIPTTEXT $timestamp"
echo ""
echo "## $SCRIPTTEXT $timestamp" | tee --append $RECENTRUN &>/dev/null
bash $DELETETEMPFILE
for f in $EVERYLISTFILEWILDCARD
do
source /etc/piholeparser/scripts/scriptvars/dynamicvariables.var
TEMPOFILE="$TEMPDIR"TEMPOFILE.txt
TEMPOFILEB="$TEMPDIR"TEMPOFILEB.txt
LISTBASENAMETXT="$BASEFILENAME".txt
echo "$LISTBASENAMETXT" | tee --append $FILETEMP &>/dev/null
done
ls $PARSEDDIR > $TEMPFILE
cat $TEMPFILE | sed '/README.md/d' > $TEMPOFILE
gawk 'NR==FNR{a[$0];next} !($0 in a)' $FILETEMP $TEMPOFILE > $TEMPOFILEB
for source in `cat $TEMPOFILEB`;
do
REMPARSEDFILE="$PARSEDDIR""$source"
if
[[ $source == *.txt ]]
then
rm $REMPARSEDFILE
printf "$red"    "The $source .lst No Longer Exists. Parsed File Deleted."
fi
done
bash $DELETETEMPFILE
echo ""
echo "" | tee --append $RECENTRUN &>/dev/null
printf "$orange" "___________________________________________________________"
echo ""

#########################
## Mirrored Not In Use ##
#########################

SCRIPTTEXT="Removing Mirrored Lists No Longer Used."
timestamp=$(echo `date`)
printf "$lightblue"    "___________________________________________________________"
echo ""
printf "$cyan"   "$SCRIPTTEXT $timestamp"
echo ""
echo "## $SCRIPTTEXT $timestamp" | tee --append $RECENTRUN &>/dev/null
bash $DELETETEMPFILE
for f in $EVERYLISTFILEWILDCARD
do
source /etc/piholeparser/scripts/scriptvars/dynamicvariables.var
TEMPOFILE="$TEMPDIR"TEMPOFILE.txt
TEMPOFILEB="$TEMPDIR"TEMPOFILEB.txt
LISTBASENAMETXT="$BASEFILENAME".txt
echo "$LISTBASENAMETXT" | tee --append $FILETEMP &>/dev/null
done
ls $MIRRORDIR > $TEMPFILE
cat $TEMPFILE | sed '/README.md/d' > $TEMPOFILE
gawk 'NR==FNR{a[$0];next} !($0 in a)' $FILETEMP $TEMPOFILE > $TEMPOFILEB
for source in `cat $TEMPOFILEB`;
do
REMMIRRORFILE="$MIRRORDIR""$source"
if
[[ $source == *.txt ]]
then
rm $REMMIRRORFILE
printf "$red"    "The $source .lst No Longer Exists. Mirror File Deleted."
fi
done
bash $DELETETEMPFILE
echo ""
echo "" | tee --append $RECENTRUN &>/dev/null
printf "$orange" "___________________________________________________________"
echo ""

