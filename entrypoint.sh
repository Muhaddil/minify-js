#!/bin/bash
npm install -g @prasadrajandran/strip-comments-cli
npm install -g uglify-js
npm install -g clean-css-cli
apt-get update
apt-get -y install moreutils

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
    uglifyjs --compress --mangle --output ${output_path} -- ${directory}
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
    stripcomments -w ${directory}
    sed -i -e ':a;N;$!ba;s/\n//g;s/\t//g;s/\s\{2,\}/ /g' ${directory}
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
