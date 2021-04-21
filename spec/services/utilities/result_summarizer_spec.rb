require 'rails_helper'

module Utilities
  RSpec.describe ResultSummarizer do
    let(:no_results) { [] }
    let(:one_pending) { %i[eligible eligible pending] }
    let(:all_eligible) { %i[eligible eligible eligible] }
    let(:all_ineligible) { %i[ineligible ineligible ineligible] }
    let(:all_contrib) { %i[contribution_required contribution_required contribution_required] }
    let(:elig_and_inelig) { %i[eligible ineligible eligible] }
    let(:elig_and_contrib) { %i[eligible contribution_required contribution_required] }
    let(:inelig_and_contrib) { %i[ineligible contribution_required contribution_required] }
    let(:all_three) { %i[eligible contribution_required ineligible] }

    subject { described_class.call(results) }

    context 'no results' do
      let(:results) { no_results }
      it 'returns :pending' do
        expect(subject).to eq :pending
      end
    end

    context 'one pending' do
      let(:results) { one_pending }
      it 'returns :pending' do
        expect(subject).to eq :pending
      end
    end

    context 'all eligible' do
      let(:results) { all_eligible }
      it 'returns :eligible' do
        expect(subject).to eq :eligible
      end
    end

    context 'all ineligible' do
      let(:results) { all_ineligible }
      it 'returns :ineligible' do
        expect(subject).to eq :ineligible
      end
    end

    context 'all eligible with contribution' do
      let(:results) { all_contrib }
      it 'returns :eligible_with_contribution' do
        expect(subject).to eq :contribution_required
      end
    end

    context 'eligble and ineligible mixed' do
      let(:results) { elig_and_inelig }
      it 'returns :partially_eligible' do
        expect(subject).to eq :partially_eligible
      end
    end

    context 'eligible and contribution_required mixed' do
      let(:results) { elig_and_contrib }
      it 'returns :eligible_with_contribution' do
        expect(subject).to eq :contribution_required
      end
    end

    context 'ineligble and contribution_required mixed' do
      let(:results) { inelig_and_contrib }
      it 'returns :partially_eligible' do
        expect(subject).to eq :partially_eligible
      end
    end

    context 'all three' do
      let(:results) { all_three }
      it 'returns :partially_eligible' do
        expect(subject).to eq :partially_eligible
      end
    end
  end
end
