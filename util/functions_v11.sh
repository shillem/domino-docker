#!/bin/bash

fix_setup_file() {
    if [ ! -e "$1" ]; then
        echo "You must specify a valid file name"
        return 1
    fi

    sed -i 's/defined(@{$scr->{target_hosts}})/@{$scr->{target_hosts}}/' "$1"

    return 0
}

fix_shebang() {
    if [ ! -e "$1" ]; then
        echo "You must specify a valid file name"
        return 1
    fi

    sed -i 's/#!\/bin\/sh/#!\/bin\/bash/' "$1"

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

    sed -i "s|USER_INSTALL_DIR=.*|USER_INSTALL_DIR=$NUI_NOTESDIR|" "$retval"
    sed -i "s|USER_INSTALL_DATA_DIR=.*|USER_INSTALL_DATA_DIR=$NUI_NOTESDIR_DATA|" "$retval"
    sed -i "s|USER_MAGIC_FOLDER_1=.*|USER_MAGIC_FOLDER_1=$NUI_NOTESDIR_DATA|" "$retval"
    sed -i "s|IA_USERNAME=.*|IA_USERNAME=$NUI_NOTESUSER|" "$retval"
    sed -i "s|IA_GROUPNAME=.*|IA_GROUPNAME=$NUI_NOTESGROUP|" "$retval"
    sed -i "s|-fileOverwrite_.*/notes|-fileOverwrite_$NUI_NOTESDIR/notes|" "$retval"

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
        echo "You must specify a profile. E.g. BASE/FP/PROTON"
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
        cd linux64
        fix_shebang "install"
        ./install -f $(prepare_config_file $RES/installer_default.properties) -i silent
        cd $RES
        rm -R linux64
        ;;
    "FP")
        tar -xf $(basename $DOWNLOAD_FILE)
        cd linux64/domino
        fix_shebang "install"
        fix_setup_file "tools/lib/NIC.pm"
        ./install -script $(prepare_config_file $RES/fp_script_default.dat)
        cd $RES
        rm -R linux64
        ;;
    "PROTON")
        mkdir proton && tar -xf $(basename $DOWNLOAD_FILE) -C proton
        chown ${NUI_NOTESUSER}.${NUI_NOTESUSER} adpconfig.ntf && chmod u=rw,g=r,o=r adpconfig.ntf && mv adpconfig.ntf ${NUI_NOTESDIR_DATA}
        mkdir proton-addin && tar -xzf proton/1101-proton-addin-*.tgz -C proton-addin
        chmod u=rwx,g=rx,o=rx proton-addin/* && mv proton-addin/* ${NUI_NOTESDIR}/notes/latest/linux
        cd ${NUI_NOTESDIR}/notes/latest/linux
        ./setup_proton.sh
        cd $RES
        rm -R proton && rm -R proton-addin
        ;;
    *)
        echo "Invalid $1 profile"
        return 1;
    esac

    rm $(basename $DOWNLOAD_FILE)
}