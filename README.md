# IMPORTANT #
This project needs to be built with the correct java sdk jar files in the right location when running gem build.
These dependencies are not packaged with this project.

The java sdk for vCloud can be found here:  [https://developercenter.vmware.com/web/sdk/5.5.0/vcloud-java](https://developercenter.vmware.com/web/sdk/5.5.0/vcloud-java)

## Myst

Myst cloud abstraction library.
A library for talking to vcloud via the java SDK.

## Build status

* Master:  [![CircleCI Master](https://circleci.com/gh/ErnestIO/myst/tree/master.svg?style=svg)](https://circleci.com/gh/ErnestIO/myst/tree/master)
* Develop: [![CircleCI Develop](https://circleci.com/gh/ErnestIO/myst/tree/develop.svg?style=svg)](https://circleci.com/gh/ErnestIO/myst/tree/develop)

## Installation

On you Gemfile
```
gem 'myst'
```

## Running Tests

```
make deps
make test
```
## Contributing

Please read through our
[contributing guidelines](CONTRIBUTING.md).
Included are directions for opening issues, coding standards, and notes on
development.

Moreover, if your pull request contains patches or features, you must include
relevant unit tests.

## Versioning

For transparency into our release cycle and in striving to maintain backward
compatibility, this project is maintained under [the Semantic Versioning guidelines](http://semver.org/).

## Copyright and License

Code and documentation copyright since 2015 r3labs.io authors.

Code released under
[the Mozilla Public License Version 2.0](LICENSE).
