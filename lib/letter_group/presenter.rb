# Purpose:
#   To assist with rendering any Array of Hashes like you get back from a raw sql query, Invariants, or Dossier Reports.
#   Due to the generic nature, with very little configuration results can be organized
#     and rendered with a single template which handles all current needs.

module LetterGroup
  class Presenter

    LETTER_MATCHER = -> to_match, letter { to_match =~ Regexp.new("^#{letter}", true) } # true makes it case insensitive
    ALPHABET = ("a".."z").to_a.freeze
    ALPHABET_AND_OTHER = (ALPHABET + ["other"]).freeze
    DEFAULT_SELECTED = ("a".."c").to_a.freeze
    IN_GROUPS = ALPHABET_AND_OTHER.each_slice(3)

    attr_reader :array_of_hashes, :groups, :total_selected, :selected, :labels

    def initialize(array_of_hashes = [], alpha_key:, unique_key:, selected: nil, field_groups: {}, labels: true)
      # With this sort of data triage many of the result rows must be combined to represent a single data issue.
      #   (the nature of SQL JOINS)
      # Thus we can only get a count by tallying up the total for each group.
      # since they each will know how to find their own unique problems
      @array_of_hashes = array_of_hashes # responds to each with PGresult-like tuples
      @fields = array_of_hashes.first ? array_of_hashes.first.keys : []
      @alpha_key = alpha_key.to_s     # like "leads_last_name" or "leads_email"
      @unique_key = unique_key.to_s   # like "leads_id" or "leads_email"
      raise ArgumentError, "#{self.class} Looks like alpha_key (#{@alpha_key} was not part of the select on fields: #{@fields.inspect}" unless @fields.empty? || @fields.include?(@alpha_key)
      raise ArgumentError, "#{self.class} Looks like unique_key (#{@unique_key} was not part of the select on fields: #{@fields.inspect}" unless @fields.empty? || @fields.include?(@unique_key)
      @field_groups = field_groups || {}
      @groups = {}
      @labels = labels
      divide_into_letters
      set_selected(selected)
      @total_selected = each.inject(0) {|memo, group| memo += group.total; memo }
      raise ArgumentError, "Unable to allocate all data into groups" unless @array_of_hashes.empty?
    end

    def each
      return enum_for(:each) unless block_given? # Sparkling magic!
      selected.each do |letter|
        for_letter = groups[letter]
        next unless for_letter
        yield for_letter
      end
    end

    def count_for(letters)
      groups.values_at(*letters).flatten.inject(0) {|memo, group| memo += group.total; memo }
    end

    private

    def enhance_by_unique_key(rows)
      unique_keys = rows.map {|x| x[@unique_key]}.uniq
      more_rows_with_same_unique_keys, @array_of_hashes = @array_of_hashes.partition do |row|
        unique_keys.include?(row[@unique_key])
      end
      more_rows_with_same_unique_keys
    end

    def divide_into_letters
      ALPHABET.each do |letter|
        rows, @array_of_hashes = @array_of_hashes.partition do |hash|
          LETTER_MATCHER.call(hash[@alpha_key], letter)
        end
        rows.concat(enhance_by_unique_key(rows))
        groups[letter] = Group.new(
            rows,
            letter: letter,
            unique_key: @unique_key,
            fields: @fields,
            field_groups: @field_groups,
            labels: labels
        )
      end
      rows, @array_of_hashes = @array_of_hashes.partition do |_|
        # Whatever is left over goes in "other" (may not have an alpha first character)
        # And @array_of_hashes becomes empty.
        true
      end
      groups["other"] = Group.new(
          rows,
          letter: "other",
          unique_key: @unique_key,
          fields: @fields,
          field_groups: @field_groups
      )
    end

    def set_selected(selected)
      @selected =  if !selected.nil? && !selected.empty?
                    custom_selected = selected.split(",").map {|x| x.strip}
                    ALPHABET_AND_OTHER.select {|x| custom_selected.include?(x) }
                  else
                    DEFAULT_SELECTED
                  end
    end

    def self.group_for_letter(letter)
      IN_GROUPS.detect {|group| group.include?(letter)}.join(",")
    end
  end
end
