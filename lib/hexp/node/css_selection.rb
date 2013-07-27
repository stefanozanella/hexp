module Hexp
  class Node
    # Select nodes using CSS selectors
    #
    class CssSelection < Selector
      def initialize(node, css_selector)
        @node, @css_selector = node, css_selector
      end

      def inspect
        "#<#{self.class} @node=#{@node.inspect} @css_selector=#{@css_selector.inspect} matches=#{node_matches?}>"
      end

      def each(&block)
        return to_enum(:each) unless block_given?

        @node.children.each do |child|
          self.class.new(child, next_comma_sequence).each(&block)
        end
        yield @node if node_matches?
      end

      private

      def comma_sequence
        @comma_sequence ||= if @css_selector.is_a? CssSelector::CommaSequence
                              @css_selector
                            else
                              CssSelector::Parser.call(@css_selector)
                            end
      end

      def node_matches?
        comma_sequence.matches?(@node)
      end

      # returns a new commasequence with the parts removed that have been consumed by matching
      # against this node. If no part matches, return nil
      def next_comma_sequence
        @next_comma_sequence ||= CssSelector::CommaSequence.new(consume_matching_heads)
      end

      def consume_matching_heads
        comma_sequence.members.flat_map do |sequence|
          if sequence.head_matches? @node
            [sequence, sequence.drop_head]
          else
            [sequence]
          end
        end.reject(&:empty?)
      end

    end
  end
end