#!/bin/bash
npm install -g minify
apt-get update
apt-get -y install moreutils

minify_file(){
    directory=$1
    basename=$(basename $directory);
    extension="${basename##*.}"
    output="";
    if [ -z "$INPUT_OUTPUT" ]
    then
        output="${directory%/*}/"
    else
        mkdir -p $INPUT_OUTPUT
        output="$INPUT_OUTPUT";
    fi
    filename="${basename%.*}"
    output_path="${output}${filename}.min.${extension}"
    rm ${output_path}

    if [ "$INPUT_OVERWRITE" = "true" ]
    then
      output_path="${output}${filename}.${extension}"
    fi

    minify ${directory} | sponge ${output_path}
    echo "Minified ${directory} > ${output_path}"
}

if [ -z "$INPUT_DIRECTORY" ]
then
    find . -type f -iname \*.css -exec sed -i -e ':a;N;$!ba;s/\n//g;s/\t//g;s/\s\{2,\}/ /g' {} \;
    find . -type f \( -iname \*.html -o -iname \*.js \) | while read fname
        do
            if [[ "$fname" != *"min."* ]]; then
                minify_file $fname
            fi
        done
else
    minify_file $INPUT_DIRECTORY
    find . -type f -iname "$INPUT_DIRECTORY/*.css" -exec sed -i -e ':a;N;$!ba;s/\n//g;s/\t//g;s/\s\{2,\}/ /g' {} \;
fi
