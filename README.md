
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

Theres also some other edge cases that can be solved with this pattern, when you need to make certain resources absent based on a flexible criteria (eg: you don't know the exact titles) you can't just declare them with ensure set to absent, so if you wanted to remove any package based on a pattern match of it's name you'd do

```puppet
  purge { 'package':
    if => [ 'name', '=~', 'acme-devel-.*' ],
  }
```


## Parameters

### if / unless

Purge resources only if or unless they meet the criteria.

Criteria is defined as an array of "parameter", "operator", and "value".

```puppet
   if => [ 'name', '==', 'root' ]
```

Operators can support `!=`,`==`,`=~`,`>`,`<`,`<=` and `>=` as an arguments

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


## Safe usage notes

If you've read this far I hope you have an idea of what purging actually does, just to clarify, it removes things from your system.  Further more, it removes things from your system that Puppet had no knowledge about so re-recreating them after the fact may not be so easy.   It's important to verify carefully the values that you pass into if and unless.   Consider this example;

```puppet
class foo ( Optional[Hash] $purge_opts = {} ) {
  purge { 'user':
    * => $purge_opts
  }
}
```

If you are using the above pattern to source the options from Hiera, you probably don't want to be doing things like allowing an empty default.  Consider what's going to happen if you tweak your hiera.yaml in such a way that stops this data from getting looked up?  Such errors normally result in things *not* being configured, in this case, it's quite the oposite.

