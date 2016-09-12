module Graph::Query
  class Range
    def initialize(range)
    end

    # https://github.com/hemanth/functional-programming-jargon#pointed-functor - chances are
    # I didn't yet understand this ;)
    def of(query)
      query
    end
  end
end
