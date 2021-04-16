[![CircleCI](https://circleci.com/gh/ministryofjustice/check-financial-eligibility.svg?style=shield)](https://circleci.com/gh/ministryofjustice/check-financial-eligibility/tree/master)
[![codecov](https://codecov.io/gh/ministryofjustice/check-financial-eligibility/branch/master/graph/badge.svg?token=1CUYQMF2BX)](https://codecov.io/gh/ministryofjustice/check-financial-eligibility)

# Ministry of Justice
test

## Legal Aid Financial Eligibility check API

An API for checking financial eligibility for legal aid

## Architecture Diagram

View the [architecture diagram](https://structurizr.com/share/55246/diagrams#cfe-container) for this project.
It's defined as code and [can be edited](https://github.com/ministryofjustice/laa-architecture-as-code/blob/main/src/main/kotlin/model/CFE.kt) by anyone.

## Documentation

The API is documented at /apidocs

The documentation and input validation is maintained via
[APIPIE](https://github.com/Apipie/apipie-rails).

## API Versioning

The API version is specified through the accept header, as follows:

    ``` Accept:application/json;version=3```

The only currently acceptable version is 3.  If no version is specified, version 3 is assumed if alternative versions are developed.


## Generation of API documentation
The documentaion is automatically generated when tests are run with an environment variable set.

```APIPIE_RECORD=examples bundle exec rspec```

This generates a JSON file `doc/apipie_examples.json` which is read and used when drilling down in the documentation available at '/apidocs'.

To add additional examples to this json file, add the `:show_in_doc` tag to the relevant rspec tests and rerun the above command.

## Setting the env vars
To run the integration tests you will need to set up a `.env` file in the root folder.

It should contain the following values:
```shell script
PRIVATE_KEY_ID
PRIVATE_KEY
CLIENT_EMAIL
CLIENT_ID
ALLOW_FUTURE_SUBMISSION_DATE
```

Set ALLOW_FUTURE_SUBMISSION_DATE to true to allow integration tests to run with submission dates that are in the future.
A copy of the `.env` file including the current values can be found in the `Shared-LAA` section of LastPass

## Threshold configuration files

Files holding details of all thresholds values used in calculating eligibility are stored in `config/thresholds`.
The file `values.yml` details the start dates for each set of thresholds, and the name of the file from which they should be read.

If a file has the key `test_only` with a value of true, then that file will only be read if the
`USE_TEST_THRESHOLD_DATA` environment variable is set to true.  This is the default for staging and UAT, and it is
false for production.

This allows the insertion of test data on an arbitrary date specified in the `values.yml` file to be used
for testing new thresholds before they come into affect on production

## Running tests

The full rspec test suite can be run with
```
bundle exec rspec
```

The repo also includes `pry-rescue`, a gem to allow faster debugging. Running
```
bundle exec rescue rspec
```
will cause any failing tests or unhandled exceptions to automatically open a `pry` prompt for immediate investigation.

## Integration tests
Several use cases and their expected results can be found in the google spreadsheet https://docs.google.com/spreadsheets/d/1jOtk5LGoVi1SxJPmRvIvZXufvH0wmYYL2NF1RlT8_RU/edit#gid=667499172 named CFE Integration Test V3.

Once the master Google spreadsheet is edited, the next time the unit test (`spec/integration/test_runner_spec.rb`) is started it will export the file to (`tmp/integration_test_data.xlsx`) and it will over-write any existing copy in the same location.

This ensures that the service returns the expected results for the use cases of the spreadsheet.

When the test is run by the command `rspec spec/integration/test_runner_spec.rb` it runs in silent mode, that is, no output except the normal green dot
to indicate all test cases in the spreadsheet have been run successfully, or red F if any of them failed.

For more fine control over the amount of verbosity, to run just one test case, or to force download the google spreadsheet,
use `bin/ispec`, the help text of which is given below.

```
      ispec - Run integration tests

      options:
        -h        Display this help text
        -r        Force refresh of Google speadsheet to local storage
        -v        Set verbosity level to 1 (default is 0: silent)
        -vv       Set verbosity level to 2
        -w XXX    Only process worksheet named XXX
  ```


## Replaying live API interactions for debugging purposes

In the event that you need to investigate why a CFE result was produced on live, there is
a way to replay the API calls of the original application and debug the assessment process
on a local machine

1) Record the original api payloads and calls on the Apply system
   Run the rake task `rake cfe:record_payloads`.  This will print to the screen a YAML
   representation of the calls to the API with the actual payloads

2) Copy and paste that output to the file `tmp/api_payloads.yml` in this repo

3) Start a CFE server locally on port 4000, and add breakpoints at the required places

4) Run the rake task `rake replay`: this will read the `tmp/api_payloads.yml` file and
   replay the original API calls and payloads enabling you to re-create the conditions.
