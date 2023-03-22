#!/bin/bash
apt-get update
apt-get -y install nodejs npm moreutils
npm install -g @prasadrajandran/strip-comments-cli
npm install -g minify
npm install -g clean-css-cli

minify_js(){
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

minify_css(){
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
    cleancss -o ${directory} ${directory} --inline none
    echo "Minified ${directory} > ${output_path}"
}

minify_html(){
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
#    stripcomments ${directory} --language=HTML | sponge ${directory}
    tr -d '\n\t' < ${directory} | sed ':a;s/\( \) \{1,\}/\1/g;ta' | sponge ${directory}
    echo "Minified ${directory} > ${output_path}"
}

if [ -z "$INPUT_DIRECTORY" ]
then
    find . -type f \( -iname \*.js \) | while read fname
        do
            if [[ "$fname" != *"min."* ]]; then
                minify_js $fname
            fi
        done
    find . -type f \( -iname \*.css \) | while read fname
        do
            if [[ "$fname" != *"min."* ]]; then
                minify_css $fname
            fi
        done
    find . -type f \( -iname \*.html \) | while read fname
        do
            if [[ "$fname" != *"min."* ]]; then
                minify_html $fname
            fi
        done
else
    minify_js $INPUT_DIRECTORY
    minify_css $INPUT_DIRECTORY
    minify_html $INPUT_DIRECTORY
fi
