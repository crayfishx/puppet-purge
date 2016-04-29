
# purge 

This is a metatype to purge resources from the agent. It behaves in a similar way to the 'resources' type native in Puppet but offers more finite control over the criteria in which resources are purged.

When run without parameters the purge type takes a resource type as a title.  The resource type must be one that has a provider that supports the instances method (eg: package, user, yumrepo).  Any instances of the resource found on the agent that are *not* in the catalog will be purged.  You can also add filter conditions to control the behaviour of purge using the if and unless parameters.

## Examples

Eg:
To remove *all* users found on the system that are not present in the
catalog (caution!):

```puppet
   purge { 'user': }
```

To remove all users found on the system but not in the catalog, unless
the user has a UID below 500:

```puppet
 purge { 'user':
  unless => [ 'uid', '<=', '500' ],
 }
```

You may also use regexes to filter, for example, to remove all unmanaged yumrepos unless they used for RHEL Satellite, you could do something like;

```puppet
  purge { 'yumrepo':
    unless => [ 'baseurl', '=~', 'http://my-satellite-server.*' ],
  }
```


## Parameters

### if / unless

Purge resources only if or unless they meet the criteria.

Criteria is defined as an array of "parameter", "operator", and "value".

```puppet
   if => [ 'name', '==', 'root' ]
```

Operators can support `!=`,`==`,`=~`,`>`,`<`,`<=` and `=>` as an arguments

Value can be a string, integer or regex (without the enclosing slashes) depending on the operator that you are using.  Note that '==' will always be a string comparrason whereas arethmetic operators such as '<=' will attempt to convert the values to integers before comparrison (if possible)

Multiple criterias can be nested in an array, eg:

```puppet
   purge { 'user':
     unless => [
       [ 'name', '==', 'root' ], 
       [ 'name', '=~', 'admin.*' ]
     ]
  }
```

