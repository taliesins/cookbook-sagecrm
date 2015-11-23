# sagecrm-cookbook

Cookbook to install Sage CRM

## Supported Platforms

Windows

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['sagecrm']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### sagecrm::default

Include `sagecrm` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[sagecrm::default]"
  ]
}
```

## License and Authors

Author:: Taliesin Sisson (<taliesins@yahoo.com>)
