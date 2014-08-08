#!/bin/bash
foundMissingTranslation=false
wordsDone=()
localizationFiles=($(find . -name Localizable.strings -type f))

if [ "${#localizationFiles[@]}" -ne 0 ] ; then
    IFS_backup=$IFS
    IFS=$'\r\n\t'
    lines=($(egrep -rho "NSLocalizedString\(@\"(.+?)\"" ./e-cal/Classes/))
    IFS=$IFS_backup

    for ((i=0;i<${#lines[*]};i++)); do
        word="$(echo "${lines[$i]}" | sed 's/NSLocalizedString(@//' | sed 's/\")/\"/')"
        if [[ " ${wordsDone[*]} " != *" $word "* ]]; then         
            for file in $localizationFiles ; do
                total="$(cat $file | grep -c "^$word")"
                if [ "$total" == "0" ] ; then
                        echo "$file:0: error: Missing translation for $word"
                        foundMissingTranslation=true
                    fi
            done
            wordsDone+=($word)
        fi
    done

    if $foundMissingTranslation; then
        exit 1
    fi
fi