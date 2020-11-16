# WSL2 and Anyconnect with Mobile Push Notification MFA
There's a couple of steps to get WSL2 working with VPN, specifically Cisco Anyconnect VPN + Mobile Push Notification MFA. Here's info that assisted me in getting it working. Many workarounds involve using the built-in Windows VPN, but note that this limits your connection speed to 10Mb/s - I've found this to be really rough when video conferencing.

There's a lot of helpful information out there, but I had not seen a complete guide.


## References
1. https://github.com/microsoft/WSL/issues/4285#issuecomment-522201021

## Installing AnyConnect (First time Setup)
If you don't have the AnyConnect standalone client already, talk to your software provisioning department. As far as I can tell the clients aren't available for direct download without a lisence.

## WSL2 resolv.conf ( first time setup )
Lets start getting things working OFF VPN first, then we'll add it into the mix later.

You'll want to update your WSL /etc/resolv.conf file to include your internal DNS servers & search configurations. By default WSL2 will override this file, so update /etc/wsl.conf to stop auto-generating /etc/resolv.conf.


In your wsl terminal:
```git@gitlab.com:tmobile/conducktor/self-service/duck-development.git
sudo su
cat > /etc/wsl.conf <<EOF
[network]
generateResolvConf = false
EOF
```


In windows CMD, `wsl --shutdown`, then start wsl again.


Back in your terminal:
```
cat > /etc/resolv.conf <<EOF
# <ADD YOUR ORG SETUP HERE>
nameserver 8.8.8.8
EOF
```

And test:
```
$ curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```

## Connectivity with AnyConnect Client ( do this every time you connect to VPN )


Connect to VPN on your AnyConnect client, authenticate and wait for the connection to fully setup. If you try to connect to internet or internal resources oin WSL2 now, you'll probably just have your requests hang.

Run Powershell as Administrator & run the following command:
```
Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Cisco AnyConnect"} | Set-NetIPInterface -InterfaceMetric 6000
```

You may get some alerts from AnyConnect that it's reverifying your connection, wait for that to finish and then test again:
```
$ curl google.com
<HTML><HEAD><meta http-equiv="content-type" content="text/html;charset=utf-8">
<TITLE>301 Moved</TITLE></HEAD><BODY>
<H1>301 Moved</H1>
The document has moved
<A HREF="http://www.google.com/">here</A>.
</BODY></HTML>
```

> NOTE: If you're usng something else to test like ping or tracepath, be aware that many organizations block certain traffic types over their VPN and these may not work.


## Addendum

### Terraform
Terraform's DNS behavior seems a bit whacky. If you're unable to pull providers during `terraform init`, you may need to temporarily re-arrange your /etc/resolv.conf to have a public DNS server as the first entry.
