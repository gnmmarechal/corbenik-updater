# corbenik-updater
Updater based on LPP-3DS for the Corbenik Custom Firmware


Based on EasyRPG 3DS Updater : RE by me.

http://gs2012.xyz

#Usage

1) Download the CIA/3DSX Release from http://gs2012.xyz/3ds/corbenik-updater


2) Install it using the appropriate method.


2) If you want Corbenik Updater to update to the non-chainloading version of Corbenik, create a file named "nochain" under the directory "/corbenik-updater".


3) If your Corbenik payload is not named "/arm9loaderhax.bin" or "/arm9loaderhax_si.bin", create a file named "/corbenik-updater.cfg" and write the path there. (ex. "/somefolder/thisiscorbenik.bin")


4) If you want the updater to automatically update to the latest available version, create a file named "useupdate" under "/corbenik-updater".


5) Run the updater. Select an option. A clean update deletes the configuration files. A dirty update keeps the configuration.


6) Congrats, you've updated Corbenik!

