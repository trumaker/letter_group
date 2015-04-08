RSpec.describe LetterGroup::Group do
  let(:array_of_hashes) {
    [ {"leads_id"=>"31998","other_id"=>"27765","leads_first_name"=>"Biff","other_first_name"=>"Carl","leads_last_name"=>"Mack","other_last_name"=>"Mack"},
      {"leads_id"=>"32072","other_id"=>"27846","leads_first_name"=>"Beth","other_first_name"=>"Dorf","leads_last_name"=>"Bogo","other_last_name"=>"Bogo"},
      {"leads_id"=>"32072","other_id"=>"28428","leads_first_name"=>"Beth","other_first_name"=>"Herb","leads_last_name"=>"Bogo","other_last_name"=>"Bogo"} ]
  }
  let(:fields) {["leads_id", "other_id", "leads_first_name", "other_first_name", "leads_last_name", "other_last_name"]}
  let(:field_groups) {
    {
        "id" => ["leads_id", "ol_id"],
        "first_name" => ["leads_first_name", "ol_first_name"],
        "last_name" => ["leads_last_name", "ol_last_name"]
    }
  }
  let(:unique_key) { "leads_id" }
  describe ".initialize" do
    context "with field_groups" do
      it("instantiates a new LetterGroup::Group") { expect(LetterGroup::Group.new(
          array_of_hashes,
          letter: "d",
          unique_key: unique_key,
          fields: nil,
          field_groups: field_groups
      )).to be_a LetterGroup::Group }
    end
    context "with fields" do
      it("instantiates a new LetterGroup::Group") { expect(LetterGroup::Group.new(
                                                               array_of_hashes,
                                                               letter: "d",
                                                               unique_key: unique_key,
                                                               fields: fields,
                                                               field_groups: nil
                                                           )).to be_a LetterGroup::Group }
    end
  end
  describe "instance methods" do
    let(:letter) { "d" }
    let(:group) { LetterGroup::Group.new(
        array_of_hashes,
        letter: letter,
        unique_key: unique_key,
        fields: fields,
        field_groups: field_groups
    )}
    describe "#rows" do
      context "with field_groups" do
        let(:fields) { nil }
        it("is a Hash") { expect(group.rows).to be_a Hash}
        it("has compacted to unique rows") { expect(group.rows.length).to eq 2 } # <= Not Three!
        it("keys are the unique_key values") { expect(group.rows.keys).to eq array_of_hashes.map {|hash| hash[unique_key] }.uniq }
        it("values are Arrays") { expect(group.rows["31998"]).to be_an Array }
      end
      context "with fields" do
        let(:field_groups) { nil }
        it("is a Hash") { expect(group.rows).to be_a Hash}
        it("has compacted to unique rows") { expect(group.rows.length).to eq 2 } # <= Not Three!
        it("keys are the unique_key values") { expect(group.rows.keys).to eq array_of_hashes.map {|hash| hash[unique_key] }.uniq }
        it("values are Arrays") { expect(group.rows["31998"]).to be_an Array }
      end
    end
    describe "#letter" do
      it("is upcased") { expect(group.letter).to eq "D" }
      context "default" do
        let(:letter) { nil }
        it("is empty string") { expect(group.letter).to eq "" }
      end
    end
    describe "total" do
      it("is equal to #rows.length") { expect(group.total).to eq group.rows.length }
    end
    describe "unique_key" do
      let(:unique_key) { "Santa Cruz" }
      it("is whatever set to") { expect(group.unique_key).to eq "Santa Cruz" }
      context "default" do
        let(:unique_key) { nil }
        it("is nil") { expect(group.unique_key).to be_nil }
      end
    end
    describe "#fields" do
      context "with field_groups" do
        let(:fields) { nil }
        it("is an Array") { expect(group.fields).to be_an Array}
        it("has compacted to unique rows") { expect(group.fields.length).to eq 3 }
        it("equals") { expect(group.fields).to eq ["id", "first_name", "last_name"] }
      end
      context "with fields" do
        let(:field_groups) { nil }
        it("is an Array") { expect(group.fields).to be_an Array}
        it("has compacted to unique rows") { expect(group.fields.length).to eq 6 }
        it("equals") { expect(group.fields).to eq ["leads_id", "other_id", "leads_first_name", "other_first_name", "leads_last_name", "other_last_name"] }
      end
    end
    describe "#field_groups" do
      context "with field_groups" do
        let(:fields) { nil }
        it("is an Array") { expect(group.field_groups).to be_a Hash}
        it("has compacted to unique rows") { expect(group.field_groups.length).to eq 3 }
        it("equals") { expect(group.field_groups).to eq field_groups }
      end
      context "with fields" do
        let(:field_groups) { nil }
        let(:default_field_groups) {
          {
              "leads_id"=>["leads_id"],
              "other_id"=>["other_id"],
              "leads_first_name"=>["leads_first_name"],
              "other_first_name"=>["other_first_name"],
              "leads_last_name"=>["leads_last_name"],
              "other_last_name"=>["other_last_name"]
          }
        }
        it("is an Array") { expect(group.field_groups).to be_a Hash}
        it("has compacted to unique rows") { expect(group.field_groups.length).to eq 6 }
        it("equals") { expect(group.field_groups).to eq default_field_groups }
      end
    end
  end

end
