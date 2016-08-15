SaltStack Tools
===============
A set of tools to run and manage SaltStack deployments.

These tools complement a package based approach to states and configuration.
The script `bin/saltify` configures the session to use these scripts.
The packages directory can be set with the `SALTIFY_PACKAGE`
environment variable and defaults to `${PWD}/../salt-packages`.


Master tests
------------
While packages are tested indipendenlty using `kitchen-salt` there is a need to
also test that a salt-master is configured correctly in a bootstrap scenario.

On top of that having a virtual `salt-master` auto-configured in minutes
is very useful for testing and experimenting.

The virtual `salt-master` is created with [kitchen](http://kitchen.ci/)
and `kitchen-docker`.
Assuming you have `ruby` and `docker` installed, run the following:
```bash
. bin/saltify
install-gems

cd test/master
./collect-packages
kitchen converge docker
```
