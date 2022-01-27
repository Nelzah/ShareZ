# CONFIG #
auth="username,password"
saveDir="/home/pi/Pictures"
imageName=$(tr -dc 'A-Z0-9a-z' < /dev/urandom | head -c4)-$(tr -dc 'A-Z0-9a-z' < /dev/urandom | head -c4)
ip='192.168.1.32'
# CONFIG #

choice=$(printf "Area Screenshot\nFull Screen Screenshot\nArea Screenshot with delay\nFull Screen Screenshot with delay\nExit" | rofi -dmenu -p "Choose an option")
if [[ $choice == *"with delay"* ]]; then
    delay=$(printf "1\n2\n3\n4\n5\n6\n7\n8\n9\n10" | rofi -dmenu -p "Choose a delay in seconds")
fi

if [ "$choice" = "Area Screenshot" ]; then
    scrot --select /tmp/$imageName.png
elif [ "$choice" = "Full Screen Screenshot" ]; then
    scrot /tmp/$imageName.png
elif [ "$choice" = "Area Screenshot with delay" ]; then
    sleep $delay && scrot --select /tmp/$imageName.png
elif [ "$choice" = "Full Screen Screenshot with delay" ]; then
    sleep $delay && scrot /tmp/$imageName.png
elif [ "$choice" = "Exit" ]; then
    exit
fi

check=$(ls /tmp/$imageName.png)

if [ "$check" == "/tmp/$imageName.png" ]; then
    notify-send "Screenshot saved"
    method=$(printf "Copy to Clipboard\nUpload to FTP" | rofi -dmenu -p "Choose a save method")
fi

if [ "$method" == "Copy to Clipboard" ]; then
    xclip -selection clipboard -t image/png -i /tmp/$imageName.png
    notify-send "Screenshot copied to clipboard"
elif [ "$method" == "Upload to FTP" ]; then
    notify-send "Uploading screenshot to FTP"
    lftp -u $auth $ip << EOF
    cd $saveDir
    put /tmp/$imageName.png
    bye
EOF
    notify-send "Screenshot uploaded to FTP"
fi

rm /tmp/$imageName.png
