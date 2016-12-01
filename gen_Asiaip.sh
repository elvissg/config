#!/bin/sh
#根据apnic生成亚洲的ip段,通过iptables控制不走ss(算了这个方案雪崩)
if [ ! -f ips.list ];then
    wget http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest -O ips.list
fi

cat /dev/null > "ss-iptables"
echo "#!/bin/sh" >> "ss-iptables"
echo "iptables -t nat -N SHADOWSOCKS" >> "ss-iptables"
echo "iptables -t nat -A SHADOWSOCKS -d 23.106.131.215 -j RETURN" >> "ss-iptables"
echo "iptables -t nat -A SHADOWSOCKS -d 192.168.31.123 -j RETURN" >> "ss-iptables"
echo "iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN" >> "ss-iptables"
echo "iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN" >> "ss-iptables"
echo "iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/16 -j RETURN" >> "ss-iptables"
echo "iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN" >> "ss-iptables"
echo "iptables -t nat -A SHADOWSOCKS -d 114.114.114.114 -j RETURN" >> "ss-iptables"
echo "iptables -t nat -A SHADOWSOCKS -d 223.5.5.5 -j RETURN" >> "ss-iptables"
echo "iptables -t nat -A SHADOWSOCKS -d 8.8.8.8 -j RETURN" >> "ss-iptables"
echo "iptables -t nat -A SHADOWSOCKS -d 8.8.4.4 -j RETURN" >> "ss-iptables"


sed -n '/ipv4/p' ips.list | awk 'BEGIN{
FS="|"
}
{
    if($4 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/){
        x=$5/2
        i=1
        while(x>1){
            x=x/2
            i++
        }
        print "iptables -t nat -A SHADOWSOCKS -d "$4"/"i" -j RETURN" >> "ss-iptables"
    }
}'

echo "iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-ports 1080" >> "ss-iptables"
echo "iptables -t nat -D SS_SPEC_WAN_FW 1" >> "ss-iptables"
echo "iptables -t nat -A PREROUTING -p tcp -j SHADOWSOCKS" >> "ss-iptables"
echo "iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS" >> "ss-iptables"


