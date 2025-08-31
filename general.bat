@echo off

set "DIR=%~dp0"

%DIR%\app\winws.exe --wf-tcp=80,443 --wf-udp=443,50000-50100 --filter-udp=50000-50100 --ipset='%DIR%\ipset\ipset-discord.txt' --dpi-desync=fake --dpi-desync-any-protocol --dpi-desync-cutoff=d3 --dpi-desync-repeats=6 --new ^

--filter-tcp=443 --hostlist='%DIR%\list\list-general.txt' --dpi-desync=split2 --dpi-desync-split-seqovl=652 --dpi-desync-split-pos=2 --dpi-desync-split-seqovl-pattern='%DIR%\app\tls_clienthello_www_google_com.bin' --new ^

--filter-tcp=443 --hostlist='%DIR%\list\list-general.txt' --dpi-desync=fake,multidisorder --dpi-desync-split-pos=midsld --dpi-desync-repeats=8 --dpi-desync-fooling=md5sig,badseq --new ^

--filter-udp=443 --ipset='%DIR%\ipset\ipset-cloudflare.txt' --dpi-desync=fake --dpi-desync-repeats=11 --dpi-desync-fake-quic='%DIR%\app\quic_initial_www_google_com.bin' --new ^

--filter-tcp=1-65535 --ipset='%DIR%\ipset\ipset-all.txt' --dpi-desync=multidisorder --dpi-desync-split-pos=midsld --dpi-desync-autottl --dpi-desync-repeats=6 --dpi-desync-fooling=md5sig,badseq --new ^

--filter-tcp=443 --hostlist='%DIR%\list\list-general.txt' --dpi-desync=split --dpi-desync-split-pos=1 --dpi-desync-autottl --dpi-desync-fooling=badseq --dpi-desync-repeats=8 --new ^

--filter-udp=1024-65535 --ipset='%DIR%\ipset\ipset-all.txt' --dpi-desync=fake --dpi-desync-autottl=2 --dpi-desync-repeats=10 --dpi-desync-any-protocol=1 --dpi-desync-fake-unknown-udp='%DIR%\app\quic_initial_www_google_com.bin' --dpi-desync-cutoff=n2 --new ^

--filter-tcp=80 --ipset='%DIR%\ipset\ipset-cloudflare.txt' --dpi-desync=fake,fakedsplit --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig --ipset='%DIR%\ipset\ipset-cloudflare.txt' --dpi-desync=fake,multidisorder --dpi-desync-split-pos=1,midsld --dpi-desync-repeats=11 --dpi-desync-fooling=md5sig

exit
