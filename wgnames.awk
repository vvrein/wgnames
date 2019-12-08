#!/usr/bin/awk -f
BEGIN {
	file="/etc/wireguard/wg0server.conf"
	indeep = 0
	while(( getline < file) > 0 ) {
		if (debug)
			print $0
		if ($1 ~ /Peer/ || indeep == 1) {
			indeep = 0
			while(1)  {
				if (( getline < file) == 0 ) { 
					if (debug)
						print "break EOF"
					break 
				}
				if ($1 ~ /Description/) { 
					split($0, text, "=")
					description = text[2]; 
					description_matched = 1
				}
				if ($1 ~ /PublicKey/) { 
					pubkey = $3; 
					pub_key_matched = 1
				}

				if (description_matched == 1 && pub_key_matched == 1) {
					if (debug)
						print "break matched"
					description_matched = 0
					pub_key_matched = 0
					break
				}
				if ($1 ~ /Peer/) {
					if (debug)
						print "break peer"
					description_matched = 0
					pub_key_matched = 0
					indeep = 1
					break
				}


			}
			description_pubkey_hash[pubkey]=description
			pubkey = ""
			description = ""
		}
	} 
}

{
	if ($0 ~ /peer:/) {
		description = description_pubkey_hash[$2]
		if (description != "")
			print "\033[38;5;198mDesc:"description"\033[0m";
		print "\033[1;32mpeer\033[0m:", "\033[38;5;28m"$2"\033[0m";
		getline;
	}
	gsub("(endpoint|allowed ips|latest handshake|transfer)", "\033[1m&\033[0m"); # Make bold
	gsub("(KiB|MiB|GiB|seconds?|minutes?|hours?|/)", "\033[38;5;45m&\033[0m");   # Make blue
	print;
}
