## 2.0.0

* The purge resource now purges directly from the generate method by calling the set method directly on a types properties,  rather than creating resources that spin off outside of the dependency graph.  This addresses [issue #5](https://github.com/crayfishx/puppet-purge/issues/5).  Adding `notify` to a purge resource will now notify the resource *after* the purges have occured.

* Due to the above the output is slightly different, rather than seeing each resource purged in Puppet's notices, there is now just one notice...

```
Notice: /Stage[main]/Main/Purge[user]/ensure: ensure changed 'purgable' to 'purged'
```

Debug logging however will show the purges...

```
Debug: Purging resource User[wham2]
```

* Added new attributes `manage_property` and `state` to allow overriding of the default "ensure => absent" behaviour for different types of resources.

## 1.1.0

* Added support for array values to criteria https://github.com/crayfishx/puppet-purge/pull/3

### 1.0.1

* Ruby 1.8.7 support

# 1.0.0

* Added many more spec tests
* Namevar changed from `name` to `resource_type`
* Added non-isomorphic behaviour
* Documentation updates



