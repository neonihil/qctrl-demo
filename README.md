# Overview

# Installation and setup

## Automatic Setup

### 1. Clone the repository 

Note: This is already done if you've used vagrant.

### 2. Prerequisites

The package is mostly automated using Make, but in order for the Makefile to work, the following tools must be available on the `$PATH`:

```
git
python
pip
virtualenv
```

The presence of these tools are checked by the Makefile. If your build fails with ```error: invalid environment configuration.``` please follow steps in the **Installing prerequisites** section below.

3. Starting the local development server

```
make dev
```

This should bring up the server on port http://localhost:8080.

You can override the port by editing `package.mk`.

** Feel free to skip to the Usage part **

## Manual setup

## Installing prerequisites

The following command are required for this package to build/work. Each command is checked during execution of the Makefile. The results of the check is saved to the `.environment` file. Environment is only re-checked if the environment does not exist. Re-check can be enforced using `make checkenv`.

If there are missing tools, the output of `make *` will look something like: 

```
checking environment....
checking git...ok
checking python...ok
checking pip...NOT FOUND
checking virtualenv...NOT FOUND
error: invalid environment configuration.
```

Please follow the guides below to install tools labeled `NOT FOUND`.

### git

Download and install platform specific version from [https://git-scm.com/download].

### python

Download an install platfrom specific version from [https://www.python.org/downloads/].

### pip

Use `easy_install` to install pip.

    sudo easy_install pip

### virtualenv

Use `pip` to install `virtualenv`

    sudo pip install virtualenv

### Multiple versions of the same tool

The contents of the .environment file contains paths to where each tool was found. If you have multiple versions of a tool you can verify which one is going to be used by looking into the `.environment` file using `cat .environment`. You should see something like:

```
cat .environment
git is /usr/bin/git
python is /usr/bin/python
pip is /usr/local/bin/pip
virtualenv is /usr/local/bin/virtualenv
```

### Virtualenv

Create the virtualenv using `make .virtualenv` or using the alias `make activate`.

Activate the virtualenv using `source activate`.

### Dependencies 

Dependencies are specified in the `requirements-.txt` files. 

Dependencies can be installed from these files into the local virtualenv using the following commands.

- `make deps`: install runtime dependencies from `requirements.txt`
- `make deps-test`: install test dependencies from `requirements-test.txt`
- `make deps-build`: install build dependencies from `requirements-build.txt`

The `make setup` executes all three targets above with a single command.

## Building and releasing

Use `make build` to build a version from the current source.

Use `make release-patch`, `make release-minor` or `make release-major` to test, build and release a new version of the package. The release includes bumping the specified version and making a new commit/tag with it.

## Rebuilding the environment

To rebuild the environment from scratch please issue the following commands:

```
make clean
make deps
```

# Usage

## Testing

Tests are implemented using `pytest`. There are two kinds of tests.

- Unit tests live in the `src/` folder and has the same name as the module they are testing suffixed by `_test`.
- End-to-end tests live under `tests/` and has the same `_test` suffix.

### Executing tests


#### Manually
Activate the `virtualenv` and use `pytest` as usual.

```
pytest src/
# or 
pytest tests/
```

#### Using Make
The tests can also be executed using Make

```
make test               # execute all tests
make test-modules       # execute all tests under src/
make test-e2e           # execute all tests under tests/
```

#### Individually using make

You can execute individual end-to-end tests using make. This is the usual way for handling the TDD dev loop.

```
make test-<filename>
```

For example, there is the initial data importer test. The test is implemented in `tests/create_initial_data_test.py`. To invoke this through make, please execute:

```
make test-create_initial_data
```

Please note that the `_test.py` suffix was moved to the front of the command with a dash as `test-`.


## Importing the dataset from `/resources`

    WARNING: This tests starts with **dropping the database** that is defined in config.

To re-create the database please issue the following command:

```
make test-create_initial_data
```


## Playing with the API

Please navigate to [http://localhost:8080/docs](http://localhost:8080/docs)

A [Swagger-UI](https://swagger.io/tools/swagger-ui/) should be loaded up with the API documentation.


