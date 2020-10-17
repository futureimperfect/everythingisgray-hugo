+++
title = "Complex LDAP Queries With ldapsearch and python-ldap"
date = "2014-06-01"
slug = "2014/06/01/complex-ldap-queries-with-ldapsearch-and-python-ldap"
published = false
Categories = ["Python", "LDAP", "Technology"]
+++

I recently needed to test a complex LDAP query in a Python script I was writing. I realized shortly after beginning to construct the query that I had never done anything more than a simple `a=b` or `a=b*` before, (where `*` is the wildcard). The solution is rather simple, albeit awkward due to the position of the binary operators. You'll notice in the examples below that the operators are positioned _before_ each operand. So rather than `a & b`, you would write `&(a)(b)`.

To test the query I used the trusty `ldapsearch` utility. For example, to find the email addresses of all users in the "Example" OU that 1) have a nickname beginning with "M", 2) are full time employees, and 3) their department number doesn't start with "5" _or_ their login shell is `/bin/bash`, use the following command:

```sh
ldapsearch -LLL -x -H ldap://ldap.example.com -b "ou=Example,dc=example,dc=com" '(&(nickname=M*)(employeeType=fulltime)(|(!(departmentNumber=5*))(loginShell=/bin/bash)))' mail | awk '/mail: / { print $2 }'
```

To perform the same query in Python, try the following:

```python
import ldap
import sys
 
LDAP_URI = 'ldap://ldap.example.com'
SEARCH_BASE = 'ou=Example,dc=example,dc=com'
QUERY = '(&(nickname=M*)(employeeType=fulltime)(|(!(departmentNumber=5*))(loginShell=/bin/bash)))'
 
 
def ldap_search(ldap_uri, base, query):
  '''
  Perform an LDAP query.
  '''
    emails = []
 
    try:
        l = ldap.initialize(ldap_uri)
        l.protocol_version = ldap.VERSION3
 
        search_scope = ldap.SCOPE_SUBTREE
        retrieve_attributes = None
 
        ldap_result_id = l.search(
            base,
            search_scope,
            query,
            retrieve_attributes
        )
        result_set = []
        while 1:
            result_type, result_data = l.result(ldap_result_id, 0)
            if (result_data == []):
                break
            else:
                if result_type == ldap.RES_SEARCH_ENTRY:
                    result_set.append(result_data)
 
        if len(result_set) == 0:
            print('No results found.')
            return
 
        count = 0
        for i in range(len(result_set)):
            for entry in result_set[i]:
                try:
                    email = entry[1]['mail'][0]
                    count += 1
                    emails.append(email)
                except:
                    pass
 
    except ldap.LDAPError, e:
        print('LDAPError: %s.' % e)
 
    finally:
        l.unbind_s()
        print(emails)
 
 
def main():
    ldap_search(LDAP_URI, SEARCH_BASE, QUERY)
 
 
if __name__ == '__main__':
    sys.exit(main())
```

Happy `LDAP`ing.
