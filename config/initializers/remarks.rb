# We need to load this class before the ActiveRecord framework as it is serialized on the Assessment model
require_relative "../../app/services/remarks"
Remarks
