## 1.2.0

### New features

Purge now supports two new attributes, `state` and `manage_property`.  `state` can be used to define a state other than `absent` for a resource, for example, to unmount mounts instead of deleting them from the config.  You can now use purge to set any desired state of a resource by combining `manage_property` with `state` to manage other properties.  See the README for more details.

### Enhancements

Purge will now use the `.should=()` method of the types property to change the state, This means that user defined values will be passed through the types property validation.  For example if you try and set a state for a resource that it doesnt support, Puppet will correctly error;

```
Puppet::Error: Invalid value :obliterated. Valid values are present, absent, role.
```
 
## 1.1.0

* Added support for array values to criteria https://github.com/crayfishx/puppet-purge/pull/3

### 1.0.1

* Ruby 1.8.7 support

# 1.0.0

* Added many more spec tests
* Namevar changed from `name` to `resource_type`
* Added non-isomorphic behaviour
* Documentation updates



