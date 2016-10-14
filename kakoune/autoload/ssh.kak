hook global BufCreate .*\.ssh/config %{
    set buffer filetype ssh
}

# Extra faces
face host 'rgb:ffa54f'
face hostdef 'magenta'
face number 'blue'

addhl -group / regions -default code ssh \
    comment '#' '$' ''

addhl -group /ssh/comment fill comment

%sh[
# Grammar
hostsect=Host

match='canonical|exec|host|originalhost|user|localuser|all'

keywords='AddressFamily|AddKeysToAgent|BatchMode|BindAddress|CanonicalDomains'
keywords="$keywords|CanonicalizeFallbackLocal|CanonicalizeHostname|CanonicalizeMaxDots"
keywords="$keywords|CertificateFile|ChallengeResponseAuthentication|CheckHostIP"
keywords="$keywords|Cipher|Ciphers|ClearAllForwardings|Compression|CompressionLevel"
keywords="$keywords|ConnectTimeout|ConnectionAttempts|ControlMaster|ControlPath"
keywords="$keywords|ControlPersist|DynamicForward|EnableSSHKeysign|EscapeChar"
keywords="$keywords|ExitOnForwardFailure|ForwardAgent|ForwardX11|ForwardX11Timeout"
keywords="$keywords|ForwardX11Trusted|GSSAPIAuthentication|GSSAPIClientIdentity"
keywords="$keywords|GSSAPIDelegateCredentials|GSSAPIKeyExchange|GSSAPIRenewalForcesRekey"
keywords="$keywords|GSSAPIServerIdentity|GSSAPITrustDNS|GSSAPITrustDns|GatewayPorts"
keywords="$keywords|GlobalKnownHostsFile|HashKnownHosts|HostKeyAlgorithms|HostKeyAlias"
keywords="$keywords|HostName|HostbasedAuthentication|HostbasedKeyTypes|IPQoS|IdentitiesOnly"
keywords="$keywords|IdentityFile|IgnoreUnknown|IPQoS|KbdInteractiveAuthentication"
keywords="$keywords|KbdInteractiveDevices|KexAlgorithms|LocalCommand|LocalForward"
keywords="$keywords|LogLevel|MACs|Match|NoHostAuthenticationForLocalhost|NumberOfPasswordPrompts"
keywords="$keywords|PKCS11Provider|PasswordAuthentication|PermitLocalCommand|Port"
keywords="$keywords|PreferredAuthentications|Protocol|ProxyCommand|ProxyUseFDPass"
keywords="$keywords|PubkeyAcceptedKeyTypes|PubkeyAuthentication|RSAAuthentication"
keywords="$keywords|RekeyLimit|RemoteForward|RequestTTY|RhostsRSAAuthentication"
keywords="$keywords|SendEnv|ServerAliveCountMax|ServerAliveInterval|SmartcardDevice"
keywords="$keywords|StrictHostKeyChecking|TCPKeepAlive|KeepAlive|Tunnel|TunnelDevice"
keywords="$keywords|UseBlacklistedKeys|UsePrivilegedPort|User|UserKnownHostsFile"
keywords="$keywords|UseRoaming|VerifyHostKeyDNS|VisualHostKey|XAuthLocation"

# Add the language's grammar to the static completion list
printf '%s\n' "hook global WinSetOption filetype=ssh %{
    set window static_words '$keywords|$hostsect|$match'
}" | tr '|' ':'

cat << ADDHL
addhl -group /ssh/code regex \b(?i)($keywords)\b 0:keyword
addhl -group /ssh/code regex \b(?i)$hostsect\b 0:host
addhl -group /ssh/code regex \b($match)\b 0:host
ADDHL
]

# Digits
addhl -group /ssh/code regex \d+ 0:number

#addhl -group /ssh/code regex '%[rhplLdun]\>'
addhl -group /ssh/code regex '[*?]' 0:string
addhl -group /ssh/code regex '\<(\d{1,3}\.){3}\d{1,3}(:\d+)?\>' 0:string
addhl -group /ssh/code regex '\<([-a-zA-Z0-9]+\.)+[-a-zA-Z0-9]{2,}(:\d+)?\>' 0:string
#addhl -group /ssh/code regex '\<(\x{,4}:)+\x{,4}[:/]\d+\>' 0:string
addhl -group /ssh/code regex '[Hh]ost\h+\K[^\n]+' 0:hostdef
addhl -group /ssh/code regex '[Hh]ost[Nn]ame\h+\K[^\n]+' 0:string

hook global WinSetOption filetype=ssh %{
    addhl ref ssh
}

hook global WinSetOption filetype=(?!ssh).* %{
    rmhl ssh
}
