RSpec.describe LetterGroup::Presenter do
  let(:array_of_hashes) {
    [
        {"leads_id"=>"30000","other_id"=>"27760","leads_first_name"=>"?What?","other_first_name"=>"Carl","leads_last_name"=>"Mack","other_last_name"=>"Mack"},
        {"leads_id"=>"30000","other_id"=>"27761","leads_first_name"=>"12345","other_first_name"=>"Carl","leads_last_name"=>"Mack","other_last_name"=>"Mack"},
        {"leads_id"=>"31998","other_id"=>"27763","leads_first_name"=>"?What?","other_first_name"=>"Carl","leads_last_name"=>"Mack","other_last_name"=>"Mack"},
        {"leads_id"=>"31998","other_id"=>"27765","leads_first_name"=>"Biff","other_first_name"=>"Carl","leads_last_name"=>"Mack","other_last_name"=>"Mack"},
        {"leads_id"=>"32072","other_id"=>"27846","leads_first_name"=>"Cat","other_first_name"=>"Dorf","leads_last_name"=>"Bogo","other_last_name"=>"Bogo"},
        {"leads_id"=>"32072","other_id"=>"28428","leads_first_name"=>"Doug","other_first_name"=>"Herb","leads_last_name"=>"Bogo","other_last_name"=>"Bogo"}
    ]
  }
  let(:field_groups) {
    {
        "id" => ["leads_id", "ol_id"],
        "first_name" => ["leads_first_name", "ol_first_name"],
        "last_name" => ["leads_last_name", "ol_last_name"]
    }
  }
  let(:selected) { "d,e,f" }
  let(:unique_key) { "leads_id" }
  describe ".initialize" do
    context "with field_groups" do
      it("instantiates a new LetterGroup::Presenter") { expect(LetterGroup::Presenter.new(
                                                               array_of_hashes,
                                                               selected: selected,
                                                               alpha_key: "leads_first_name",
                                                               unique_key: unique_key,
                                                               field_groups: field_groups
                                                           )).to be_a LetterGroup::Presenter }
    end
    context "without field_groups" do
      it("instantiates a new LetterGroup::Presenter") { expect(LetterGroup::Presenter.new(
                                                               array_of_hashes,
                                                               selected: selected,
                                                               alpha_key: "leads_first_name",
                                                               unique_key: unique_key,
                                                               field_groups: nil
                                                           )).to be_a LetterGroup::Presenter }
    end
  end
  describe "instance methods" do
    let(:selected) { "d,e,f" }
    let(:presenter) { LetterGroup::Presenter.new(
        array_of_hashes,
        selected: selected,
        alpha_key: "leads_first_name",
        unique_key: unique_key,
        field_groups: field_groups
    )}
    describe "#array_of_hashes" do
      it("is emptied by initialization") { expect(presenter.array_of_hashes).to be_empty }
    end
    describe "#groups" do
      it("values are LetterGroup::Group objects") { expect(presenter.groups.values.first).to be_a LetterGroup::Group }
      it("has all the keys") { expect(presenter.groups.keys.sort).to eq LetterGroup::Presenter::ALPHABET_AND_OTHER.sort }
      it("keys paired with values by unique_key ") {
        expect(presenter.groups["b"].rows["31998"].length).to eq 2
        expect(presenter.groups["b"].rows["31998"][0]["leads_first_name"]).to eq "Biff"
        expect(presenter.groups["b"].rows["31998"][1]["leads_first_name"]).to eq "?What?"
        expect(presenter.groups["c"].rows["32072"][0]["leads_first_name"]).to eq "Cat"
        expect(presenter.groups["c"].rows["32072"][1]["leads_first_name"]).to eq "Doug"
        expect(presenter.groups["other"].rows["30000"][0]["leads_first_name"]).to eq "?What?"
        expect(presenter.groups["other"].rows["30000"][1]["leads_first_name"]).to eq "12345"
      }
    end
    describe "#total_selected" do
      let(:selected) { "a,b,c" }
      it("is the total of all selected groups") { expect(presenter.total_selected).to eq presenter.each.inject(0) {|memo,elem| memo += elem.total; memo} }
    end
    describe "#selected" do
      context "default" do
        let(:selected) { nil }
        it("is a,b,c") { expect(presenter.selected).to eq ["a","b","c"] }
      end
      context "with spaces" do
        let(:selected) { "d, e, f" }
        it("is d,e,f") { expect(presenter.selected).to eq ["d","e","f"] }
      end
      context "without spaces" do
        let(:selected) { "d,e,f" }
        it("is d,e,f") { expect(presenter.selected).to eq ["d","e","f"] }
      end
    end
  end

end
