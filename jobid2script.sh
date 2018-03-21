#!/bin/bash

jq="/usr/bin/jq" # Path to jq version 1.5 or later, may be different for you

# Take a DNAnexus job ID and turn it into a shell script

jobid="YOUR_JOB_ID_HERE"
outfile="YOUR_OUTPUT_FILE.sh"

# Save the job information as json data
js=$( dx describe $jobid --json )

# Variables we need
project_id=$( echo $js | $jq -r '.project' )
project=$( dx describe $project_id --json | $jq -r ' .name ' )
applet_id=$( echo $js | $jq -r '.applet' )
applet=$( dx describe $applet_id --json | $jq -r ' .name ' )
folder=$( echo $js | $jq -r '.folder' )
instanceType=$( echo $js | $jq -r '.instanceType' )
keys=( $( echo $js | $jq -r '.["runInput"] | keys_unsorted[]' ) )
values=( $( echo $js | $jq -r '.runInput | .[] | if type == "object" then .["$dnanexus_link"].project + ":" + .["$dnanexus_link"].id else . end' ) )

# Loop through values, find file ids, and convert them to be human readable
for i in "${!values[@]}" ; do 
    val="${values[$i]}"
    if [[ "$val" == project* ]] ; then
	prj_id=$( echo "$val" | cut -d':' -f1 ) # project id
	file_id=$( echo "$val" | cut -d':' -f2 ) # file id
	prj_name=$( dx describe $prj_id --json | $jq -r ' .name ' )
	file_folder=$( dx describe $file_id --json | $jq -r ' .folder ' )
	file_name=$( dx describe $file_id --json | $jq -r ' .name ' )
	if [[ "$file_folder" == "/" ]] ; then
	    values[$i]="$prj_name:/$file_name"
	else 
	    values[$i]="$prj_name:$file_folder/$file_name"
	fi
    fi
done

# keys and values should be the same length, but check anyways
if [[ "${#keys[@]}" != "${#values[@]}" ]] ; then
    echo "Number of input names does not match number of input values, please examine!!"
    exit 0
fi

# Write out the command to a file
echo "#!/bin/bash" > $outfile
echo "" >> $outfile
echo "# dx run script created for job: $jobid" >> $outfile
echo "" >> $outfile
echo "dx run $project:/$applet --folder=\"$folder\" --instance-type=\"$instanceType\" --yes \\" >> $outfile
last_index=$(( ${#keys[@]} - 1 ))
for i in "${!keys[@]}" ; do
    if [[ "$i" != "$last_index" ]] ; then
        echo -e "\t-i${keys[$i]}=\"${values[$i]}\" \\" >> $outfile
    else 
        echo -e "\t-i${keys[$i]}=\"${values[$i]}\"" >> $outfile
    fi
done

