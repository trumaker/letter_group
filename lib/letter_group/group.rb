# Whereas multiple rows in a result set from a join with a group by may be more correctly considered as a single result,
#   this class represents a group of rows together representing something unique
# It also allows for grouping the data in each hash into rows within each row, using the concept of field_groups.
# Note: the group total is often 1 if there are no other rows to group with it
#
# Example: If we have the following rows (hashes where column names are keys):
#   params array_of_hashes - a set of data that has not yet been organized into distinct results
#     e.g.
#   [
#     {"leads_id"=>"31998","ol_id"=>"27765","leads_first_name"=>"Dan","ol_first_name"=>"Taylor"},
#     {"leads_id"=>"32072","ol_id"=>"27846","leads_first_name"=>"Dave","ol_first_name"=>"Yancy"},   # <= since leads_id is the unique_key
#     {"leads_id"=>"32072","ol_id"=>"28428","leads_first_name"=>"Davis","ol_first_name"=>"Jaunty"}  # <= these two are really a single result
#   ]
#   param letter - the letter of the alphabet which this set of results are being grouped together by
#                   used by the presentation as the heading for the group.
#                   e.g. "D"
#                   default ""
#   param unique_key - The key which designates uniqueness.
#                     e.g. "leads_id"
#                     default nil
#   param fields - optional, and if field_groups has keys, then passed in value of fields is ignored.
#                   e.g. ["leads_id","ol_id","leads_first_name","ol_first_name","leads_last_name","ol_last_name"]
#                   default []
#   param field_groups - optional, and if provided will be used to determine fields.
#                         If field_groups and fields are both provided field_groups takes precedence
#                         Used when you have multiple columns which are similar in nature and the data would be nicely stacked in the view.
#                         e.g. {
#                               "id" => ["leads_id", "ol_id"],
#                               "name" => ["leads_first_name", "ol_first_name"]
#                               }
#                         default {}

module LetterGroup
  class Group

    attr_reader :rows, :letter, :total, :unique_key, :fields, :field_groups, :labels

    def initialize(array_of_hashes = [], letter: "", unique_key: nil, fields: [], field_groups: {})
      @array_of_hashes = array_of_hashes || []
      @letter = (letter || "").upcase
      # when unique_key is nil results in a single Tuple with a set for all the rows in this group.
      @unique_key = unique_key
      determine_fields(fields, field_groups)
      fill_rows
    end

    def each
      return enum_for(:each) unless block_given? # Sparkling magic!
      rows.each do |_, tuple|
        yield tuple
      end
    end

    private
    def unique_tuple_hash_builder
      Hash.new do |hash, key|
        hash[key] = @array_of_hashes.select {|x| x[@unique_key] == key }
      end
    end

    def determine_fields(fields, field_groups)
      field_groups ||= {}
      if field_groups.keys.any?
        @field_groups = field_groups
        @fields = field_groups.keys
      else
        fields ||= []
        @fields, non_matching_fields = fields.partition {|x| x == unique_key}
        @fields.concat(non_matching_fields)
        @field_groups = @fields.inject({}) {|memo, elem| memo[elem] = Array(elem); memo}
      end
      @num_fields = @fields.length
      # The column names in the first field_group will be used as labels in the view.
      # so for { "ID" => ["lead_id", "user_id"] }
      # the labels are the array ["lead_id","user_id"]
      @labels = if @field_groups.first
                  @field_groups.first[1]
                else
                  []
                end
    end

    def fill_rows
      @unique_values = @array_of_hashes.map {|x| x[@unique_key] }.uniq
      @rows = @unique_values.inject(unique_tuple_hash_builder) do |memo, value|
        memo[value]
        memo
      end
      @total = rows.length
    end

  end
end
