RSpec.describe MonthlyEquivalentCalculatable do
  subject(:result) { klass.new.call(frequency, value) }

  let(:klass) do
    Class.new do
      include MonthlyEquivalentCalculatable

      def call(frequency, value)
        send(determine_calc_method(frequency), value)
      end

    private

      def blunt_average(value)
        value
      end
    end
  end

  context "with frequency of three_monthly" do
    let(:frequency) { :three_monthly }
    let(:value) { 1000.00 }

    it "divides by 3 and rounds to 2 decimals" do
      expect(result).to be 333.33
    end
  end

  context "with frequency of monthly" do
    let(:frequency) { :monthly }
    let(:value) { 1000.001 }

    it "returns input value unaltered" do
      expect(result).to be 1000.001
    end
  end

  context "with frequency of four weekly" do
    let(:frequency) { :four_weekly }
    let(:value) { 1000.00 }

    it "divides by 4, multiples by 52, divides by 12 and rounds to 2 decimals" do
      expect(result).to be 1083.33
    end
  end

  context "with frequency of two weekly" do
    let(:frequency) { :two_weekly }
    let(:value) { 1000.00 }

    it "divides by 2, multiples by 52, divides by 12 and rounds to 2 decimals" do
      expect(result).to be 2166.67
    end
  end

  context "with frequency of weekly" do
    let(:frequency) { :weekly }
    let(:value) { 1000.00 }

    it "multiples by 52, divides by 12 and rounds to 2 decimals" do
      expect(result).to be 4333.33
    end
  end

  context "with invalid frequency" do
    let(:frequency) { :quarterly }
    let(:value) { 1000.00 }

    it "raises error" do
      expect { result }.to raise_error(ArgumentError, "unexpected frequency quarterly")
    end
  end

  context "with frequency of unknown" do
    subject(:result) { instance.call(:unknown, 111.11) }

    let(:instance) { klass.new }

    it "calls blunt_average of owning class" do
      allow(instance).to receive(:blunt_average).and_return("foobar")
      expect(result).to match("foobar")
      expect(instance).to have_received(:blunt_average).with(111.11)
    end
  end

  context "with frequency as string" do
    subject(:result) { instance.call("weekly", 1000.00) }

    let(:instance) { klass.new }

    it "calls matching calculation method" do
      allow(instance).to receive(:weekly_to_monthly).and_call_original
      expect(result).to be 4333.33
      expect(instance).to have_received(:weekly_to_monthly).with(1000.00)
    end
  end
end
