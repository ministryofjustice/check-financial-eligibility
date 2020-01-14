# Ministry of Justice
## Legal Aid Financial Eligibility check API

An API for checking financial eligibility for legal aid

## Documentation

The API is documented at /apidocs

The documentation and input validation is maintained via
[APIPIE](https://github.com/Apipie/apipie-rails).

## API Versioning

The API version is specified through the accept header, as follows:

    ``` Accept:application/json;version=2```

Acceptable versions are 1 and 2.  If no version is specified, version1 is assumed.


## Generation of API documentation
The documentaion is automatically generated when tests are run with an environment variable set.

```APIPIE_RECORD=examples bundle exec rspec```

This generates a JSON file `doc/apipie_examples.json` which is read and used when drilling down in the documentation available at '/apidocs'.

## Integration tests
Several use cases and their expected results can be found in the google spreadsheet https://docs.google.com/spreadsheets/d/16X7ORqVRpC0BMxgsXn8_NR9ul4MNPWUbYqmpeoBstIo .

This online spreadsheet is exported as an `.xlsx` file, and copied inside the project (`spec/fixtures/integration_test_data.xlsx`) and a unit test (`spec/services/integration_tests/test_runner_spec.rb`) ensures that the service returns the expected results for the use cases of the spreadsheet.  Ensure that if the master Google spreadsheet is edited, it is exported as an `.xlsx` and copied into the above location in the project.

To run just the integration tests and see detailed output, run: 
   
   ```VERBOSE=true bundle exec rspec spec/services/integration_tests/test_runner_spec.rb```

or more simply:

   ```rake integration```



    
