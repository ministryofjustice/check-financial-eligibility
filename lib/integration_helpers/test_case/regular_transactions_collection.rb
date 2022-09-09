require Rails.root.join("lib/integration_helpers/test_case/regular_transaction.rb")

module TestCase
  class RegularTransactionsCollection
    def initialize(rows)
      @collection = []
      populate(rows)
    end

    def url_method
      :assessment_regular_transactions_path
    end

    def payload
      {
        regular_transactions: @collection.map(&:payload),
      }
    end

    def empty?
      @collection.empty?
    end

  private

    def populate(rows)
      return unless rows

      rowsets = delete_rowsets(rows)

      while rowsets.any?
        rowset = delete_rowset(rowsets)
        type = type_for_rowset(rowset)
        add_payload(type, rowset)
      end
    end

    def delete_rowsets(rows)
      end_index = rows.find_index { |r| r.first.present? && r.first != "regular_transactions" }
      rows.shift(end_index.to_i)
    end

    def delete_rowset(rows)
      rows.shift(rowset_size)
    end

    def type_for_rowset(rowset)
      rowset.first[type_column_no].presence
    end

    def rowset_size
      2
    end

    def type_column_no
      1
    end

    def rowset_class
      RegularTransaction
    end

    def add_payload(type, rowset)
      @collection << rowset_class.new(type, rowset)
    end
  end
end
