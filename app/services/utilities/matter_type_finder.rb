module Utilities
  class MatterTypeFinder
    MATTER_TYPES = {
      DA001: "domestic_abuse",
      DA002: "domestic_abuse",
      DA003: "domestic_abuse",
      DA004: "domestic_abuse",
      DA005: "domestic_abuse",
      DA006: "domestic_abuse",
      DA007: "domestic_abuse",
      DA020: "domestic_abuse",
      SE003: "section8",
      SE004: "section8",
      SE013: "section8",
      SE014: "section8",
    }.freeze

    def self.call(proceeding_type_code)
      new(proceeding_type_code).call
    end

    def initialize(proceeding_type_code)
      @proceeding_type_code = proceeding_type_code.to_sym
    end

    def call
      MATTER_TYPES.fetch(@proceeding_type_code)
    end
  end
end
