#!/bin/bash

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
        output="$INPUT_OUTPUT"
    fi
    filename="${basename%.*}"
    output_path="${output}${filename}.min.${extension}"
    if [ -f ${output_path} ]
    then
        rm ${output_path}
    fi
    

    if [ "$INPUT_OVERWRITE" == "true" ]
    then
      output_path=$directory
    fi
    extension_lower=$(echo "${extension}" | tr '[:upper:]' '[:lower:]')

    case $extension_lower in
      "css")
        minify_css ${directory} ${output_path}
        ;;

      "js")
        minify_js ${directory} ${output_path}
        ;;

      "html")
        minify_html ${directory} ${output_path}
        ;;
      *)
        echo "Couldn't minify file! (unknown file extension: ${extension})"
        return 1
    esac

    echo "Minified ${directory} > ${output_path}"
}

minify_js(){
    directory=$1
    output_path=$2
    minify ${directory} | sponge ${output_path}
}

minify_css(){
    directory=$1
    output_path=$2
    npx postcss ${directory} --use cssnano --no-map | sponge ${output_path}
}

minify_html(){
    directory=$1
    output_path=$2
    html-minifier-terser --collapse-whitespace --conservative-collapse --remove-comments --minify-css true --minify-js true ${directory} | sponge ${output_path}
}

if [ -z "$INPUT_DIRECTORY" ]
then
    dir="."
else
    dir=$INPUT_DIRECTORY
fi

find ${dir} -type f \( -iname \*.html -o -iname \*.js -o -iname \*.css \) | while read fname
    do
        if [[ "$fname" != *".min."* ]]; then
            minify_file $fname
        fi
    done
