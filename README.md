[![CircleCI](https://circleci.com/gh/ministryofjustice/check-financial-eligibility.svg?style=shield)](https://circleci.com/gh/ministryofjustice/check-financial-eligibility/tree/main)

# Ministry of Justice

## This is a fork of Check Financial Eligibility API

The fork is to allow the Estimate Eligibility team to add partner functionality without impacting other users of the API. The intention is to merge this fork back into the main service at a later date.

## Legal Aid Financial Eligibility check API

An API for checking financial eligibility for legal aid

## Architecture Diagram

View the [architecture diagram](https://structurizr.com/share/55246/diagrams#cfe-container) for this project.
It's defined as code and [can be edited](https://github.com/ministryofjustice/laa-architecture-as-code/blob/main/src/main/kotlin/model/CFE.kt) by anyone.

## Documentation

Current Rswag documentation can be found at `/api-docs`.

## API Versioning

The API version is specified through the accept header, as follows:

```text
Accept:application/json;version=3
```

The only currently acceptable version is 3.  If no version is specified, version 3 is assumed if alternative versions are developed.


## System architecture

### Database Architecture

The database structure is visualized in this [ORM diagram](https://docs.google.com/drawings/d/1fgr-33x-kAwCkXcvr9GJ8xBs7DAbUnPCwTjrSZo74Tg/edit?usp=sharing)

Each assessment has a `CapitalSummary`, a `GrossIncomeSummary` and a `DisposableIncomeSummary`, to encapsulate the totals and results of the three means assessments that are performed, the capital assessment, the gross income assessment and the disposable income assessment,
in order to arrive at an overall means assessment of the application.

Each summary record has one or more sub records that record the individual items/transactions: The `CapitalSummary` has capital items,
the `GrossIncomeSummary` has income transactions of various types, and the `DisposableIncomeSummary` various outgoings.

Each of the three summary records also has a number of Eligibility records - one for each proceeding type specified on the assessment.  The eligibility record the upper and lower thresholds for that proceeding type, and will eventually hold the result for that proceeding type.

### Usage

The client will create an assessment by posting a payload to the `/assessments` endpoint, which will respond with an `assessment_id`.  This assessment id
is then given on all subsequent posts to the other endpoints to build up a record of capital, income and outgoings, finally requesting an assessment result
by sending a GET request to the /assessments endpoint.

**TODO** When in future this API has endpoints to allow direct submission of monthly income and outgoings figures (rather than collections of transactions from which these figures are inferred), make clear in the documentation for those endpoints that for controlled work that the API client should only submit figures that are valid for the calendar month leading up to the submission date, not an average of the previous 3 months.

### Logic flow

The `AssessmentController` calls the `MainWorkflow`, which immediately branches off to the `PassportedWorkflow` or `UnpassportedWorkflow`.  The main difference is that unpassported applications are assessed on capital, gross income and disposable income, whereas passported applications are only assessed on capital.

In each case, the workflow takes each of the assessments in turn, calls a collator to look at all the sub-records under the summary and come up with a total figure in the case of capital, or a monthly equivalent figure in the case of gross or disposable  income, and these results are stored on the associated summary record.  After collation, an assessor is called for each summary which stores the results (eligible, ineligible, contribution required) in each of the eligibility records (one for each proceeding type).  Finally, the main assessor is called to work out the overall result for each proceeding type taking into account the results from the capital, gross income and disposable income assessments.  The assessments controller then calls the main decorator to format the output in the required structure to send back to the client.

## Generation of API documentation using Rswag

see [Rswag readme](https://github.com/rswag/rswag/blob/master/README.md) for initial setup and/or modifications.

The `swagger` folder in the root directory has one `swagger.yaml` within a version number folder - e.g. `swagger/v4/swagger.yaml`. This file is what defines the swagger ui page displayed at `/api-docs`. This file is generated using rswag's rake task - `rake rswag:specs:swaggerize`.

The `swagger.yaml` file that is generated is defined by a combination of "global" settings in `spec/swagger_helper.rb` and indivual spec files that are, by our convention, stored in `spec/requests/swagger_docs/<version>/*.spec.rb`.

You can generate a new endpoint spec file using:
```sh
rails generate rspec:swagger MyController
```

You can update an existing endpoint by modifying it's spec and then running:
```sh
rake rswag:specs:swaggerize
```

## Threshold configuration files

Files holding details of all thresholds values used in calculating eligibility are stored in `config/thresholds`.
The file `values.yml` details the start dates for each set of thresholds, and the name of the file from which they should be read.

If a file has the key `test_only` with a value of true, then that file will only be read if the
`USE_TEST_THRESHOLD_DATA` environment variable is set to true.  This is the default for staging and UAT, and it is
false for production.

This allows the insertion of test data on an arbitrary date specified in the `values.yml` file to be used
for testing new thresholds before they come into affect on production.

## Developer Setup

1.  Ensure Ruby is installed - for example using rbenv - with the version specified in `.ruby-version`

2.  Install these system dependencies:

    ```sh
    brew install shared-mime-info
    brew install postgresql
    ```

3.  Run the setup script:

    ```sh
    bin/setup
    ```

    This installs Ruby gem dependencies and setup the local postgres with the development and test databases.

## Running the API locally

Start rails server:

```sh
bin/rails server
```

A simple test that it's working:
```
$ curl http://127.0.0.1:3000/healthcheck
{"checks":{"database":true}}
```

## Tests

There are several kinds of tests:

* Integration tests using Spreadsheets
* Integration tests using Cucumber
* other RSpec tests

### Setup for running tests

#### Environment variables for Integration tests (spreadsheets)

Before you can run the spreadsheet integration tests you will need to set up a `.env` file in the root folder of your clone of this repo.

Obtain the `.env` file from LastPass - look in the folder `Shared-LAA-Eligibility`, under item `Environment variables to run CFE ISPEC (spreadsheet) tests`. Reach out to the team if you don't have access.

Environment variables:

| Name | Value examples & commentary |
| GOOGLE_SHEETS_PRIVATE_KEY_ID | (secret) |
| GOOGLE_SHEETS_PRIVATE_KEY | (secret) |
| GOOGLE_SHEETS_CLIENT_EMAIL | (secret) |
| GOOGLE_SHEETS_CLIENT_ID | (secret) |
| ALLOW_FUTURE_SUBMISSION_DATE | `true` allows integration tests to run with submission dates that are in the future / `false` |
| RUNNING_AS_GITHUB_WORKFLOW | `TRUE` / `FALSE` |
| LEGAL_FRAMEWORK_API_HOST | `https://legal-framework-api-staging.apps.live-1.cloud-platform.service.justice.gov.uk` |
```

### Running RSpec tests

The RSpec test suite includes "Integration tests (spreadsheets)" and "other RSpec tests", but not "Integration tests (cucumber)"

Run them with:

```sh
bundle exec rspec
```

The repo also includes `pry-rescue`, a gem to allow faster debugging. Running
```
bundle exec rescue rspec
```
will cause any failing tests or unhandled exceptions to automatically open a `pry` prompt for immediate investigation.

#### Common errors

Error:

   An error occurred while loading ./spec/integration/policy_disregards_spec.rb.
   Failure/Error: require File.expand_path("../config/environment", __dir__)

   NoMethodError:
     undefined method `gsub' for nil:NilClass

Solution: fix your .env file. See: [Environment variables for Integration tests (spreadsheets)](#environment-variables-for-integration-tests-spreadsheets)

Error:

   An error occurred while loading ./spec/validators/json_validator_spec.rb.
   Failure/Error: ActiveRecord::Migration.maintain_test_schema!

   ActiveRecord::NoDatabaseError:
     We could not find your database: cfe_civil_test. Which can be found in the database configuration file located at config/database.yml.

Solution: fix your database, which should have been created with `bin/setup` - see [Developer setup](developer-setup)

### Integration tests (spreadsheets)

A series of spreadsheets is used to provide use cases and their expected results, and are run as part of the normal `rspec` test suite, or can be run individually with more control using the script `bin/ispec` (see below).

The [Master CFE Integration Tests Spreadsheet](https://docs.google.com/spreadsheets/d/1lkRmiqi4KpoAIxzui3hTnHddsdWgN9VquEE_Cxjy9AM/edit#gid=651307264) lists all the other spreadsheets to be run, as well as contain skeleton worksheets for creating new tests scenarios.  Each spreadsheet can hold multiple worksheets, each of which is a test scenario.

You can run these tests, in the standard rspec way:

```sh
bundle exec rspec --pattern=spec/integration/test_runner_spec.rb -fd
```

Each worksheet is a test scenario, which is run as an rspec example.

For more fine control over the amount of verbosity, to run just one test case, or to force download the google spreadsheet,
use `bin/ispec`, the help text of which is given below.

```text
ispec - Run integration tests

options:
-h        Display this help text
-r        Force refresh of Google speadsheet to local storage
-v        Set verbosity level to 1 (default is 0: silent) - produce detailed expected and actual results
-vv       Set verbosity level to 2 - display all payloads, and actual and expected results
-w XXX    Only process worksheet named XXX
```

Each worksheet has an entry `Test Active` which can be either true or false.  If set to false, the worksheet will be skipped, unless it is
the named worksheet using the `-w` command line switch.

### Integration tests (cucumber)

We are [trialling the use of cucumber for integration tests](https://dsdmoj.atlassian.net/wiki/spaces/LE/pages/4229660824/Architectural+Design+Records#Cucumber-tests-trial-in-CFE-Partner), in particular to document features added for the "[EFE](https://github.com/ministryofjustice/laa-estimate-financial-eligibility-for-legal-aid)" client. These cucumber tests are to be found in the `features` folder.

Run them with:

```
bundle exec cucumber
```

### Other RSpec tests

The aim is for these to be "unit test" style - i.e. numerous tests that cover the detail of the functionality - the bottom level of the [test pyramid](https://martinfowler.com/articles/practical-test-pyramid.html).

Run them with:

```sh
bundle exec rspec --exclude-pattern=spec/integration/test_runner_spec.rb
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

## Deployment
Secrets have been stored for each environment using `kubectl create secret`. The following secrets are currently in use:

* sentry-dsn
* notifications-api-key
* secret-key-base
* postgresql-postgres-password (for UAT only, as this environment has a pod running Postgres instead of an RDS instance)
