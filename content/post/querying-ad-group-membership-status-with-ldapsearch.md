+++
title = "Querying AD Group Membership Status With ldapsearch"
date = "2014-01-02"
slug = "2014/01/02/querying-ad-group-membership-status-with-ldapsearch"
published = false
Categories = ["OS X", "Unix", "Technology"]
Tags = ["OS X", "Unix", "Technology"]
+++

Here's a way to query Active Directory for group membership status with the `ldapsearch` utility. In my case, this was used to check if a user is authorized before attempting to mount an SMB share at login on OS X clients. The `-Q` option causes `ldapsearch` to use [SASL][1] quiet mode and not prompt for a password, which works if a [Kerberos][2] ticket is present.

```sh
#!/bin/bash

console_user="$(/usr/bin/stat -f%Su /dev/console)"
ldap_uri="ldap://example.com"
search_base="DC=example,DC=com"
group="Some Group"
is_member_of_group=`/usr/bin/ldapsearch -LLL -Q -H "$ldap_uri" -b "$search_base" "sAMAccountName=$console_user" sAMAccountName | $grep "OU=$group"` # -Q prevents the authentication prompt, works if kerberos ticket exists

if [[ "${#is_member_of_group}" -ne "0" ]]; then
    echo "$console_user is a member of $group."
    # Do something about it
else
    echo "$console_user is NOT a member of $group."
    # Do something else
fi

exit $?
```

[1]: http://en.wikipedia.org/wiki/Simple_Authentication_and_Security_Layer
[2]: http://web.mit.edu/~kerberos/
