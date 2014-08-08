#!/bin/bash

localizationFiles=($(find . -not -path "./Pods/*" -name Localizable.strings -type f))

if [ "${#localizationFiles[@]}" -ne 0 ] ; then

    foundMissingTranslation=false
    declare -a wordsDone
    
    IFS_backup=$IFS
    IFS=$'\r\n\t'
    lines=($(egrep -rho --include="*.m" --exclude-dir=Pods "NSLocalizedString\(@\"(.+?)\"" .))
    IFS=$IFS_backup

    for ((i=0;i<${#lines[*]};i++)); do
        word="$(echo "${lines[$i]}" | sed 's/NSLocalizedString(@//' | sed 's/\")/\"/')" 

        for ((a=0;a<${#localizationFiles[*]};a++)); do
            file="${localizationFiles[$a]}"
            wordFile="||${file}:${word}||"

            if [[ "${wordsDone[*]}" != *"$wordFile"* ]]; then        
                total="$(cat $file | grep -c "^$word")"
                if [ "$total" == "0" ] ; then
                    echo "$file:0: error: Missing translation for $word"
                    foundMissingTranslation=true
                fi
                wordsDone[${#wordsDone[@]}]="$wordFile"
            fi
        done
    done
fi


if $foundMissingTranslation; then
    exit 1
fi