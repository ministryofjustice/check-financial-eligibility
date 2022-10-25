
[![CircleCI](https://circleci.com/gh/ministryofjustice/check-financial-eligibility.svg?style=shield)](https://circleci.com/gh/ministryofjustice/check-financial-eligibility/tree/main)

# Ministry of Justice


## Legal Aid Financial Eligibility check API

An API for checking financial eligibility for legal aid

## Architecture Diagram

View the [architecture diagram](https://structurizr.com/share/55246/diagrams#cfe-container) for this project.
It's defined as code and [can be edited](https://github.com/ministryofjustice/laa-architecture-as-code/blob/main/src/main/kotlin/model/CFE.kt) by anyone.

## Documentation

API documentation is currently being migrated from [APIPIE](https://github.com/Apipie/apipie-rails) to [rswag](https://github.com/rswag/rswag).

Current APIPIE documentation can be found at `/apidocs`.

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

### Logic flow

The `AssessmentController` calls the `MainWorkflow`, which immediately branches off to the `PassportedWorkflow` or `UnpassportedWorkflow`.  The main difference is that unpassported applications are assessed on capital, gross income and disposable income, whereas passported applications are only assessed on capital.

In each case, the workflow takes each of the assessments in turn, calls a collator to look at all the sub-records under the summary and come up with a total figure in the case of capital, or a monthly equivalent figure in the case of gross or disposable  income, and these results are stored on the associated summary record.  After collation, an assessor is called for each summary which stores the results (eligible, ineligible, contribution required) in each of the eligibility records (one for each proceeding type).  Finally, the main assessor is called to work out the overall result for each proceeding type taking into account the results from the capital, gross income and disposable income assessments.  The assessments controller then calls the main decorator to format the output in the required structure to send back to the client.


## Generation of API documentation using APIPIE
The documentation is automatically generated when tests are run with an environment variable set.

```shell
APIPIE_RECORD=examples bundle exec rspec
```

This generates a JSON file `doc/apipie_examples.json` which is read and used when drilling down in the documentation available at '/apidocs'.

To add additional examples to this json file, add the `:show_in_doc` tag to the relevant rspec tests and rerun the above command.

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

## Setting the env vars
To run the integration tests you will need to set up a `.env` file in the root folder.

It should contain the following values:
```shell script
PRIVATE_KEY_ID
PRIVATE_KEY
CLIENT_EMAIL
CLIENT_ID
ALLOW_FUTURE_SUBMISSION_DATE
LEGAL_FRAMEWORK_API_HOST
```

Set ALLOW_FUTURE_SUBMISSION_DATE to true to allow integration tests to run with submission dates that are in the future.
A copy of the `.env` file including the current values can be found in the `Shared-LAA` section of LastPass.

## Threshold configuration files

Files holding details of all thresholds values used in calculating eligibility are stored in `config/thresholds`.
The file `values.yml` details the start dates for each set of thresholds, and the name of the file from which they should be read.

If a file has the key `test_only` with a value of true, then that file will only be read if the
`USE_TEST_THRESHOLD_DATA` environment variable is set to true.  This is the default for staging and UAT, and it is
false for production.

This allows the insertion of test data on an arbitrary date specified in the `values.yml` file to be used
for testing new thresholds before they come into affect on production.

## Setup

You can run `bin/setup` from the command line to install dependencies and setup the development and test databases.

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
A series of spreadsheets is used to provide use cases and their expected results, and are run as part of the normal `rspec` test suite, or can be run individually with more control using the script `bin/ispec` (see below).

There is a  [Master CFE Integration Tests Spreadsheet](https://docs.google.com/spreadsheets/d/1lkRmiqi4KpoAIxzui3hTnHddsdWgN9VquEE_Cxjy9AM/edit#gid=651307264) which lists all the other spreadsheets to be run, as well as contain skeleton worksheets for creating new tests scenarios.  Each spreadsheet can hold multiple worksheet, each of which is a test scenario.

When run as part of the `rspec` test suite each worksheet is handled as a separate example.

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
