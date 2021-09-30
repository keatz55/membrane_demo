#!/bin/bash

COMMAND=""

for (( i=1; i<=$(($1*2)); i+=2 ))
do  
    COMMAND+=" gst-launch-1.0 -v \
        audiotestsrc \
        ! audio/x-raw,rate=44100 \
        ! faac \
        ! rtpmp4gpay pt=127 ssrc=$i \
        ! srtpenc key="7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A" \
            rtp-cipher="aes-128-icm" rtp-auth="hmac-sha1-80" \
            rtcp-cipher="aes-128-icm" rtcp-auth="hmac-sha1-80" \
        ! udpsink host=127.0.0.1 port=5000 \
        videotestsrc \
        ! video/x-raw,format=I420 \
        ! x264enc key-int-max=10 tune=zerolatency \
        ! rtph264pay pt=96 ssrc=$(($i+1)) \
        ! srtpenc key="7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A7A" \
            rtp-cipher="aes-128-icm" rtp-auth="hmac-sha1-80" \
            rtcp-cipher="aes-128-icm" rtcp-auth="hmac-sha1-80" \
        ! udpsink host=127.0.0.1 port=5000 &"
done

COMMAND+="& fg"

eval $COMMAND
