# Ministry of Justice
## Legal Aid Financial Eligibility check API

An API for checking financial eligibility for legal aid

[![CircleCI](https://circleci.com/gh/ministryofjustice/check-financial-eligibility/tree/master.svg?style=svg)](https://circleci.com/gh/ministryofjustice/check-financial-eligibility/tree/master)

## Documentation

The API is documented at /apidocs

The documentation and input validation is maintained via
[APIPIE](https://github.com/Apipie/apipie-rails).

## API Versioning

The API version is specified through the accept header, as follows:

    ``` Accept:application/json;version=2```

The only currently acceptable version is 2.  If no version is specified, version 2 is assumed.


## Generation of API documentation
The documentaion is automatically generated when tests are run with an environment variable set.

```APIPIE_RECORD=examples bundle exec rspec```

This generates a JSON file `doc/apipie_examples.json` which is read and used when drilling down in the documentation available at '/apidocs'.

## Setting the env vars
To run the integration tests you will need to set up a `.env` file in the root folder.  

It should contain the following values:
```shell script
PRIVATE_KEY_ID
PRIVATE_KEY
CLIENT_EMAIL
CLIENT_ID
``` 
A copy of the `.env` file including the current values can be found in the `Shared-LAA` section of LastPass

## Integration tests
Several use cases and their expected results can be found in the google spreadsheet https://docs.google.com/spreadsheets/d/16X7ORqVRpC0BMxgsXn8_NR9ul4MNPWUbYqmpeoBstIo .

Once the master Google spreadsheet is edited, the next time the unit test (`spec/integration/test_runner_spec.rb`) is started it will export the file to (`tmp/integration_test_data.xlsx`) and it will over-write any existing copy in the same location.

This ensures that the service returns the expected results for the use cases of the spreadsheet.

To run just the integration tests and see detailed output, run: 
   
   ```VERBOSE=true bundle exec rspec spec/integration/test_runner_spec.rb```

or more simply:

* ```rake integration``` to run verbose, or
* ```rake integration[silent]``` to run in silent mode
