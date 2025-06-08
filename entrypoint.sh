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

      "js"|"ts")
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
    local input_file=$1
    local output_path=$2

    esbuild "${input_file}" --minify --outfile="${output_path}" --allow-overwrite || cp "${input_file}" "${output_path}"
}

minify_css(){
    local input_file=$1
    local output_path=$2
    lightningcss --minify --output-file "$output_path" "$input_file" || cp "$input_file" "$output_path"
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

export -f minify_file minify_js minify_css minify_html

find "$dir" -type f \( -iname '*.html' -o -iname '*.js' -o -iname '*.css' \) ! -name '*.min.*' | parallel -j $(nproc) minify_file {}