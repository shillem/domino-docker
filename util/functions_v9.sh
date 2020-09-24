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

run_installer() {
    if [ -z "$1" ]; then
        echo "You must specify a profile. E.g. BASE/FP/HF/NTF/PROTON/SEOS"
        return 1
    fi

    DOWNLOAD_FILE=$(get_file_property "url_path_default.txt" "$1")

    if [ -z "$DOWNLOAD_FILE" ]; then
        echo "Did not find $1. Skipping"
        return 0;
    else
        echo "Found $1"
    fi

    echo "Downloading ${DOWNLOAD_SERVER}/$DOWNLOAD_FILE"

    wget -q ${DOWNLOAD_SERVER}/$DOWNLOAD_FILE

    case "$1" in
    "BASE")
        tar -xf $(basename $DOWNLOAD_FILE)
        cd linux64/domino
        bash -c "./install -silent -options $(prepare_config_file $RES/server_response_default.dat)"
        cd $RES
        rm -R linux64
        ;;
    "FP")
        tar -xf $(basename $DOWNLOAD_FILE)
        cd linux64/domino
        fix_setup_file "tools/lib/NIC.pm"
        bash -c "./install -script $(prepare_config_file $RES/fp_script_default.dat)"
        cd $RES
        rm -R linux64
        ;;
    "HF")
        tar -xf $(basename $DOWNLOAD_FILE)
        cd linux64
        fix_setup_file "tools/lib/NIC.pm"
        bash -c "./install -script $(prepare_config_file $RES/hf_script_default.dat)"
        cd $RES
        rm -R linux64
        ;;
    "NTF")
        unzip -o $(basename $DOWNLOAD_FILE) -d ${NUI_NOTESDIR_DATA}
        chown -R ${NUI_NOTESUSER}.${NUI_NOTESUSER} ${NUI_NOTESDIR_DATA}
        ;;
    "PROTON")
        mkdir proton && tar -xf $(basename $DOWNLOAD_FILE) -C proton
        mkdir proton-addin && tar -xzf proton/proton-addin-*.tgz -C proton-addin
        chmod u=rwx,g=rx,o=rx proton-addin/* && mv proton-addin/* ${NUI_NOTESDIR}/notes/latest/linux
        rm -R proton && rm -R proton-addin
        ;;
    "SEOS")
        tar -xf $(basename $DOWNLOAD_FILE)
        cd linux64
        chmod +x install
        bash -c "./install -silent -options $(prepare_config_file $RES/seos_response_default.dat)"
        cd $RES
        rm -R linux64
        ;;
    *)
        echo "Invalid $1 profile"
        return 1;
    esac

    rm $(basename $DOWNLOAD_FILE)
}