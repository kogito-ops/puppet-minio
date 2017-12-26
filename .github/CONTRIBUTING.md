# Contributing

Hey, welcome! Great that you use our project and would like to add your own
spices to it :simple_smile:

## Just a few small steps

Submitting your improvements is only a few steps away:

1. Fork the repo.
2. Create a separate branch for your change.
3. Run the tests. We only take pull requests with passing tests, and
   documentation.
4. Add a test for your change. Only refactoring and documentation
   changes require no new tests. If you are adding functionality
   or fixing a bug, please add a test.
5. Squash your commits down into logical components. Make sure to rebase
   against the current master.
6. Push the branch to your fork and submit a pull request.

Please be prepared to repeat some of these steps as our contributors review
your code.

## Dependencies

This is super easy, promise! All you need is the [Puppet Development Kit][pdk]
installed on your system.

## Syntax and style

The test suite will run [Puppet Lint][puppet-lint] and [Puppet Syntax][puppet-syntax]
to check various syntax and style things. You can run these locally with:

```bash
pdk validate
```

## Running the unit tests

The unit test suite covers most of the code, as mentioned above please add tests
if you're adding new functionality. If you've not used [rspec-puppet][rspec-puppet]
before then feel free to ask about how best to test your new feature.

To run your all the unit tests

```bash
pdk test unit
```

## Integration tests

The unit tests just check the code runs, not that it does exactly what
we want on a real machine. For that we're using [beaker][beaker].

This fires up a new virtual machine (using vagrant) and runs a series of
simple tests against it after applying the module. You can run this
with:

```bash
pdk bundle -- exec rake beaker
```

This will run the tests on a Debian 8 (Jessie) virtual machine. You can also
run the integration tests against Centos 6.5 with.

```bash
BEAKER_set=centos-7 pdk bundle -- exec rake beaker
```

If you don't want to have to recreate the virtual machine every time you can use
`BEAKER_DESTROY=no` and `BEAKER_PROVISION=no`. On the first run `BEAKER_PROVISION`
should be set to yes (the default).

[pdk]: https://puppet.com/download-puppet-development-kit
[puppet-support-matrix]: http://docs.puppetlabs.com/guides/platforms.html#ruby-versions
[puppet-lint]: http://puppet-lint.com/
[puppet-syntax]: https://github.com/gds-operations/puppet-syntax
[rspec-puppet]: http://rspec-puppet.com/
[beaker]: https://github.com/puppetlabs/beaker
