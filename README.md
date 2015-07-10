XcodeMissingTranslationsErrors
==============================

A shell script to show errors for any missing translations used by NSLocalizedString at runtime.

## Result
<br>
![Example](https://raw.github.com/e-sites/XcodeMissingTranslationsErrors/master/Assets/screenshot.png)

## Code
```Shell
#!/bin/bash
NSLocalizedString="NSLocalizedString"

IFS_backup=$IFS
IFS=$'\r\n\t'
localizationFiles=($(find . -not -path "./Pods/*" -not -path "*.bundle*" -not -path "./.svn/*" -name Localizable.strings -type f))

# Does the project contain any Localizable.strings files?
if [ "${#localizationFiles[@]}" -ne 0 ] ; then


    foundMissingTranslation=false
    declare -a wordsDone

    # First search for all the NSLocalizedString() calls in the entire project (only .m files)
    lines=($(egrep -rho --include="*.m" --exclude-dir=Pods "${NSLocalizedString}\(@\".+?\"" .))

    for ((i=0;i<${#lines[*]};i++)); do
        word="${lines[$i]}"

        # Strip NSLocalizedString(@", so only "<word>" remains
        word=${word:((${#NSLocalizedString} + 2)):((${#word} - NSLocalizedStringLength))}

        # Iterate through the localization files
        for ((a=0;a<${#localizationFiles[*]};a++)); do
            file="${localizationFiles[$a]}"
            wordFile="[${file}:${word}]"
            # If <word> isn't checked yet in <file>
            if [[ "${wordsDone[*]}" != *"$wordFile"* ]]; then
                total="$(cat $file | grep -c "^$word")"

                # Find the total occurences of <word> at the beginning of the line in <file>
                if [ "$total" == "0" ] ; then
                    echo "$file:0: error: Missing translation for $word"
                    foundMissingTranslation=true
                fi
                wordsDone[${#wordsDone[@]}]="$wordFile"
            fi
        done
    done

    # Check for duplicate keys
    for ((a=0;a<${#localizationFiles[*]};a++)); do
        filename="${localizationFiles[$a]}"
        dupes=`cut -d' ' -f1 "$filename" | sort | uniq -d`

        while read -r line; do
            if [[ $line == "\""* ]] ;
            then
                echo "$file:0: warning: $line used multiple times"
            fi
        done <<< "$dupes"
    done
fi
IFS=$IFS_backup

if $foundMissingTranslation; then
    exit 1
fi
```

## Installation
Simply copy paste the above code to your `Build Phase` > `Run script` section
