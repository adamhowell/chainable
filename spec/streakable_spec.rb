require 'spec_helper'

describe Chainable do
  let(:user) { User.create }

  let!(:posts) do
    post_dates.map do |date|
      user.posts.create(created_at: date)
    end
  end
  let(:post_dates) { [] }

  around do |example|
    Time.zone = 'Eastern Time (US & Canada)'
    Timecop.freeze(Time.current) do
      example.run
    end
  end

  describe "#chain" do
    subject { user.chain(:posts) }

    context "user has no posts" do
      before { expect(user.posts).to be_empty }
      it { is_expected.to be 0 }
    end

    context "user posted on each of the last three days" do
      let(:post_dates) { [Time.current-2.days, Time.current-1.days, Time.current] }

      it "returns the chain" do
        expect(subject).to eq(posts.size)
      end
    end

    context "user only has a post today" do
      let(:post_dates) { [Time.current] }
      before do
        expect(user.posts.length).to eql(1)
        expect(user.posts.first.created_at.in_time_zone.to_date).to eql(Date.current)
      end

      it "returns the chain of 1" do
        expect(subject).to eq(1)
      end
    end

    context "user has chain today, and a longer chain before that" do
      let(:post_dates) { [Time.current-5.days, Time.current-4.days, Time.current-3.days, Time.current-1.days, Time.current] }

      it "still returns the current chain" do
        expect(subject).to eq(2)
      end

      context "with longest option" do
        subject { user.chain(:posts, longest: true) }

        it "returns the longer chain" do
          expect(subject).to eq(3)
        end
      end
    end

    context "user has chain today, and a shorter chain before that" do
      let(:post_dates) { [Time.current-5.days, Time.current-4.days, Time.current-2.days, Time.current-1.days, Time.current] }

      it "still returns the current chain" do
        expect(subject).to eq(3)
      end

      context "with longest option" do
        subject { user.chain(:posts, longest: true) }

        it "still returns the longer chain" do
          expect(subject).to eq(3)
        end
      end
    end

    context "user didn't post today, but has a chain before that" do
      let(:post_dates) { [Time.current-3.days, Time.current-2.days, Time.current-1.day] }
      before { expect(post_dates.map(&:to_date)).to_not include(Date.current) }

      it "returns chain of zero" do
        expect(subject).to eq(0)
      end

      context "except today" do
        subject { user.chain(:posts, except_today: true) }

        it "returns the chain" do
          expect(subject).to eq(post_dates.size)
        end
      end

      context "but has three chains, longest in the middle" do
        let(:post_dates) { [Date.current-3, Date.current-4, Date.current-6, Date.current-7, Date.current-8, Date.current-10, Date.current-11] }

        it "returns 0" do
          expect(subject).to eq(0)
        end
      end
    end

    context "spanning two months" do
      let(:freeze_time) { Time.current.beginning_of_month }
      let(:post_dates) { [1.day.ago, Time.current] }

      it "returns a chain of 2" do
        expect(subject).to eq(2)
      end
    end
  end

  describe "#chains" do
    subject { user.chains(:posts) }

    context "user has no posts" do
      before { expect(user.posts).to be_empty }
      it { is_expected.to eql([]) }
    end

    context "user posted on each of the last two days" do
      let(:post_dates) { [1.day.ago, Time.current] }

      it "returns the chains" do
        expect(subject).to eq([[Date.current, 1.day.ago.to_date]])
      end
    end

    context "user posted on each of the last three days" do
      let(:post_dates) { [Time.current-2.days, Time.current-1.days, Time.current] }

      it "returns the chains" do
        expect(subject).to eq([[Date.current, Date.current-1, Date.current-2]])
      end
    end

    context "user only has a post today" do
      let(:post_dates) { [Time.current] }
      before do
        expect(user.posts.length).to eql(1)
        expect(user.posts.first.created_at.in_time_zone.to_date).to eql(Date.current)
      end

      it "returns the chains of 1" do
        expect(subject).to eq([[Date.current]])
      end
    end

    context "user only has a post yesterday" do
      let(:post_dates) { [Time.current-1.day] }
      before do
        expect(user.posts.length).to eql(1)
        expect(user.posts.first.created_at.in_time_zone.to_date).to eql(Date.current-1)
      end

      it "returns the chain of 1" do
        expect(subject).to eq([[Date.current-1]])
      end
    end

    context "user has chain today, and a longer chain before that" do
      let(:post_dates) { [Time.current, Time.current-1.days, Time.current-3.days, Time.current-4.days, Time.current-5.days] }

      it "returns the chains" do
        expected = [[Date.current, Date.current-1], [Date.current-3, Date.current-4, Date.current-5]].map do |x|
          x.map(&:to_date)
        end

        expect(subject).to eq(expected)
      end
    end

    context "user didn't post today, but has a chain of 3 before that" do
      let(:post_dates) { [Time.current-1.days, Time.current-2.days, Time.current-3.days] }

      it "returns the chain" do
        expected = [[Date.current-1, Date.current-2, Date.current-3]].map do |x|
          x.map(&:to_date)
        end

        expect(subject).to eq(expected)
      end
    end

    context "user has three chains, longest in the middle" do
      let(:post_dates_dates_ago) { [3, 4, 6, 7, 8, 10, 11] }
      let(:post_dates) do
        post_dates_dates_ago.map {|n| Time.current - n.days}
      end

      let(:expected_days_ago) do
        [[3, 4], [6, 7, 8], [10, 11]].map do |list|
          list.map {|n| Date.current - n}
        end
      end

      it "returns the chains" do
        expect(subject).to eq(expected_days_ago)
      end
    end
  end
end
