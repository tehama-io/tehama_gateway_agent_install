#!/bin/bash

#v1.0
# Validate permissions and dependencies
#

if [ `id -u` != 0 ]; then
    echo "Need to be root to run this script"
    exit 1
fi

#
# Globals
#

download=false
this_dir=`pwd`
vela_host="https://app.tehama.io"
zip_file="gatewayagent.zip"
download_path="${vela_host}/${zip_file}"
program="${this_dir}/agent"

rclocal=
if [ -f /etc/rc.d/rc.local ]; then
    rclocal=/etc/rc.d/rc.local
elif [ -f /etc/rc.local ]; then
    rclocal=/etc/rc.local
fi

# Check for dependencies (wget, curl, unzip)
wgetcmd=`which wget 2>/dev/null`
wgetexists=$?

curlcmd=`which curl 2>/dev/null`
curlexists=$?

unzipcmd=`which unzip`
unzipexists=$?

#
# Functions
#

function usage() {
    echo
    echo "Usage: $0 [-d] [-h]"
    echo "    -d: Download and install the latest agent from Vela. If not provided, this script assumes"
    echo "    that it is in the directory with contents of the unzipped agent"
    echo
    echo "    -h: Print this help text and exit"
    echo
    exit 2
}

function check_deps() {
    if [ $download != "true" ]; then
        return 0
    fi

    if [ $unzipexists != 0 ];then
        echo "Required tool: unzip does not exist. Install and retry."
        exit 1
    fi

    if [ $wgetexists != 0 ] && [ $curlexists != 0 ];then
        echo "Required tools: wget and curl both do not exist. Install one and retry."
        exit 1
    fi
}

function do_download() {
    echo "Downloading the agent zip file"

    # Backup the zip file if it exists
    mv -f "$zip_file" "${zip_file}.`date +'%s'`.bak"

    # Download the agent zip file from Vela
    if [ $wgetexists -eq 0 ]; then
        wget "$download_path"
    else
        curl "$download_path" -o "$zip_file"
    fi

    if [ $? -ne 0 ]; then
        echo "Failed to download agent"
        exit 1
    fi
}

#
# Parse script options
#

while getopts "dh" opt; do
    case $opt in
        d)
            download=true        
            ;;
        h)
            usage
            ;;
        \?)
            usage
            ;;
    esac
done

#
# Check dependencies
#

check_deps

#
# Download the agent as required
#

# Download the zip file if the -d flag was speficied
if [ "$download" == "true" ]; then

    do_download

    # Backup this script to run the new version
    echo "Backing up this script to $0.bak"
    mv $0 $0.bak

    echo "Unzipping the downloaded agent"
    unzip -o "$zip_file"
    if [ $? -ne 0 ]; then
        echo "Failed to unzip gateway agent"
        mv $0.bak $0 # Revert the script from backup
        exit 1
    fi

    if [ -x $0 ]; then
        echo "Running newer script $0"
        $0
        exit 0
    else
        echo "No new script found in download, restoring this version"
        mv $0.bak $0
    fi
fi

#
# Verify agent and .env are present
#

if [ ! -f agent ] || [ ! -f .env ]; then
    echo "Missing required agent files. Please re-run with the '-d' flag provided or in the correct directory"
    exit 1
fi

#
# Make agent executable
#
chmod +x agent

# Generate Key File.
secret_file=secret.sck
if [ -f "$secret_file" ]; then
    echo "'$secret_file' exists, Continuing to load the Agent..."
else
    while true
    do
        read -p $'\e[01;33mPlease paste your Vela Room key here and press enter:  \e[0m' key    
        read -p $'\e[01;33mAre you sure this secret is correct? (y/n)  \e[0m' answer    
        if [ "$answer" == "y" ] || [ "$answer" == "yes" ];
        then
            echo $key > "$secret_file"
            break
        fi
    done
fi

# Add the agent line to rclocal if not already present
if [ ! -z "$rclocal" ]; then

    if [ -f "$rclocal" ]; then
        rclocalbak=${rclocal}.`date +'%s'`.bak
        echo "Backing up $rclocal to $rclocalbak"
        cp -f "$rclocal" "$rclocalbak"
    else
        touch "$rclocal"
        if [ $? -ne 0 ]; then
            echo "Failed to create $rclocal"
            exit 1
        fi
    fi

    if [ ! -x "$rclocal" ]; then
        echo "Making $rclocal executable"

        chmod +x "$rclocal"
        if [ $? -ne 0 ]; then
            echo "Failed to set permissions for $rclocal"
            exit 1
        fi
    fi

    cmd="nohup bash -c \"cd `dirname $program` && $program 2>&1 &\""

    grep "$cmd" "$rclocal"
    if [ $? -ne 0 ]; then
        # Remove any exit that might exist in rc.local
        sed -i 's/^exit.*//' "$rclocal"

        echo "Adding the command >$cmd< to the file $rclocal"
        echo "$cmd" >> "$rclocal"
        echo "exit 0" >> "$rclocal"
    fi

else
    echo "No rc.local file located. The agent will not auto-start on system reboot"
fi
    
# Run the agent
echo "Running the agent with the command 'nohup $program 2>&1 &'"
nohup "$program" 2>&1 &
