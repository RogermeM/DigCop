rm report.md
rm memory_file_timeline.txt
rm memory_process.txt
rm usn_timeline_original.csv
rm usnjournal

mkdir -p ./Exports/Registry_Files
mkdir -p ./Exports/MFT
mkdir -p ./Exports/USNJ
mkdir -p ./Exports/Email
mkdir -p ./Exports/WebHistory

echo '# Disk Information' >> report.md
fdisk -l '/media/d0ge/Kali Linux/p2p/Disk_Image_ID-20210327.001' >> report.md

echo '# System & User Information' >> report.md
echo 'Mounting Disk_Image_ID-20210327.001 ...'
sudo losetup --partscan --find --show --read-only '/media/d0ge/Kali Linux/p2p/Disk_Image_ID-20210327.001'
sudo mount /dev/loop6p2 /mnt/nist_dataleak_p2p

cp /mnt/nist_dataleak_p2p/Windows/System32/config/SOFTWARE ./Exports/Registry_Files
cp /mnt/nist_dataleak_p2p/Windows/System32/config/SYSTEM ./Exports/Registry_Files
cp /mnt/nist_dataleak_p2p/Windows/System32/config/SECURITY ./Exports/Registry_Files
cp /mnt/nist_dataleak_p2p/Windows/System32/config/SAM ./Exports/Registry_Files
cp /mnt/nist_dataleak_p2p/Users/Kamryn/NTUSER.DAT ./Exports/Registry_Files

echo '## Timezone' >> report.md
rip.pl -r ./Exports/Registry_Files/SYSTEM -p timezone >> report.md

echo '## System Information' >> report.md
rip.pl -r ./Exports/Registry_Files/SOFTWARE -p winver >> report.md

echo '## System Name' >> report.md
rip.pl -r ./Exports/Registry_Files/SYSTEM -p compname >> report.md

echo '## User Accounts' >> report.md
rip.pl -r ./Exports/Registry_Files/SAM -p samparse | grep -E 'Username|Created|Date' --color=none >> report.md

echo '## Last Account logon' >> report.md
rip.pl -r ./Exports/Registry_Files/SOFTWARE -p lastloggedon >> report.md

echo '## Last Shut Down' >> report.md
rip.pl -r ./Exports/Registry_Files/SYSTEM -p shutdown >> report.md

echo '## User Recently Opened' >> report.md
rip.pl -r ./Exports/Registry_Files/NTUSER.DAT -p recentdocs >> report.md

echo '## Installed Application' >> report.md
rip.pl -r ./Exports/Registry_Files/SOFTWARE -p installer >> report.md

echo '## Uninstalled Application' >> report.md
rip.pl -r ./Exports/Registry_Files/SOFTWARE -p uninstall >> report.md

echo '## Recent Docs' >> report.md
rip.pl -r ./Exports/Registry_Files/NTUSER.DAT -p recentdocs >> report.md

echo '# File Activity Timeline' >> report.md
python '/media/d0ge/Kali Linux/p2p/tools/USN-Record-Carver-master/usncarve.py' -f '/media/d0ge/Kali Linux/p2p/Disk_Image_ID-20210327.001' -o usnjournal
python '/media/d0ge/Kali Linux/p2p/tools/USN-Journal-Parser-master/usnparser/usn.py' -f usnjournal -b -o usn.body
mactime -d -b usn.body -m -z UTC 2021-03-10..2021-03-28 >> usn_timeline_original.csv

echo 'Please see USN journal Timeline in Exports/USNJ/usnj.csv' >> report.md

echo '# Email' >> report.md
icat -o 104448 Disk_Image_ID-20210327.001 93677-128-3 >> ./Exports/Email/INBOX
icat -o 104448 Disk_Image_ID-20210327.001 93847-128-3 >> ./Exports/Email/Sent-1
icat -o 104448 Disk_Image_ID-20210327.001 85034-128-3 >> ./Exports/Email/Drafts-1
echo 'Please see Inbox in Exports/Email/INBOX with prefix mutt -f' >> report.md
echo 'Please see Inbox in Exports/Email/Sent-1 with prefix mutt -f' >> report.md
echo 'Please see Inbox in Exports/Email/Drafts-1 with prefix mutt -f' >> report.md
#mutt -f ./Exports/Email/INBOX -R
#mutt -f ./Exports/Email/Sent-1 -R
#mutt -f ./Exports/Email/Drafts-1 -R

echo '# Network' >> report.md
rip.pl -r ./Exports/Registry_Files/SYSTEM -p nic2 >> report.md

echo '# Web Browser History' >> report.md
icat -o 104448 Disk_Image_ID-20210327.001 94798-128-3 >> ./Exports/WebHistory/History
icat -o 104448 Disk_Image_ID-20210327.001 94619-128-4 >> ./Exports/WebHistory/WebCache.dat
strings ./Exports/WebHistory/WebCache.dat | grep -i 'http' | head -n 30 >> report.md


echo '# Memory Analysis' >> report.md

echo '## Running Process' >> report.md
python '/media/d0ge/Kali Linux/p2p/tools/volatility3-develop/vol.py' -f '/media/d0ge/Kali Linux/p2p/Memory_Dump_ID-20210327.raw' windows.pstree.PsTree >> memory_process.txt
echo 'The information of running process has been saved in the file memory_process.txt' >> report.md

echo '## Running Process' >> report.md
python '/media/d0ge/Kali Linux/p2p/tools/volatility3-develop/vol.py' -f '/media/d0ge/Kali Linux/p2p/Memory_Dump_ID-20210327.raw' timeliner.Timeliner >> memory_file_timeline.txt
echo 'The information of running process has been saved in the file memory_file_timeline.txt' >> report.md

