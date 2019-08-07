# Ministry of Justice
## Legal Aid Financial Eligibility check API

An API for checking financial eligibility for legal aid

## Documentation

The API is documented at /apidocs

The documentation and input validation is maintained via
[APIPIE](https://github.com/Apipie/apipie-rails).


## Generation of API documentation
The documentaion is automatically generated when tests are run with an environment variable set.

```APIPIE_RECORD=examples bundle exec rspec```

This generates a JSON file `doc/apipie_examples.json` which is read and used when drilling down in the documentation available at '/apidocs'.

## Integration tests
Several use cases and their expected results can be found in a test google spreadsheet.

A rake task can be run to test that the service is working as expected (work in progress):

`bin/rails integration_test:run_use_case['Passported - Test 1']`

This task and its associated unit tests require a google service account and several environment variables to be set.

Creating a google service account: https://github.com/gimite/google-drive-ruby/blob/master/doc/authorization.md#on-behalf-of-no-existing-users-service-account

The spreadsheet needs to be shared with the service account.

env variables:
```
GOOGLE_CLIENT_EMAIL # email of the service account
GOOGLE_PRIVATE_KEY # private key of the service account
TEST_SPREADSHEET_ID # ID of test spreadsheet. Can be found in the URL of the spreadsheet
TEST_SERVICE_URL # URL of service to test. e.g. http://localhost:3000
```
