require_package 'graph/sentiments'

module Process
  class GraphQuery
    # ACCESS TO FUNCTIONS

    def initialize(f, fi)
      @f = f; @fi = fi
    end
    attr_accessor :f, :fi

    # TRAITS

    # Parse and set params.
    #
    #   def create(params)
    #     params_from(params)
    #     param :name, String [, required: ]
    #     ...
    #
    def params_from(params)
      @params = params
    end

    def param(name, type, required: true)
      value = @params[name.to_s]

      # TODO Validate

      instance_variable_set(:"@#{name}", value)
    end

    def returns_json
      if @result.is_a?(Array)
        f.many_json[@result]
      else
        f.json[@result]
      end
    end

    def has_range
      @range = Graph::Query::Range.new(params[:range])
    end
  end
end
