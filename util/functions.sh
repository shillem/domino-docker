#!/bin/bash

fix_setup_file() {
    if [ ! -e "$1" ]; then
        echo "You must specify a valid file name"
        return 1
    fi

    sed -i 's/defined(@{$scr->{target_hosts}})/@{$scr->{target_hosts}}/' "$1"

    return 0
}

get_file_property() {
    file=$(resolve_file "$1")

    if [ -z "$2" ]; then
        echo "You must specify a key"
        return 1
    fi

    echo $(cat $file | grep "^$2" | cut -d'=' -f2)
}

prepare_config_file() {
    retval=$(resolve_file "$1")

    sed -i "s|installLocation=\".*\"|installLocation=\"$NUI_NOTESDIR\"|" "$retval"
    sed -i "s|normalData.installLocationData=\".*\"|normalData.installLocationData=\"$NUI_NOTESDIR_DATA\"|" "$retval"
    sed -i "s|NameUserGroupPanel.UserName=\".*\"|NameUserGroupPanel.UserName=\"$NUI_NOTESUSER\"|" "$retval"
    sed -i "s|NameUserGroupPanel.GroupName=\".*\"|NameUserGroupPanel.GroupName=\"$NUI_NOTESUSER\"|" "$retval"

    echo "$retval"
}

resolve_file() {
    if [ ! -e "$1" ]; then
        echo "You must specify a valid file name"
        return 1
    fi

    custom_file=$(echo $1 | sed -e "s/_default//")

    if [ -e "$custom_file" ]; then
        retval=$custom_file
    else
        retval=$1
    fi

    echo "$retval"
}