require_package 'fdsl/fdsl'

require_relative 'error'

module API
  Functions = FDSL.create do |f|
    fi = f

    # [SinatraParams, [rule_spec]] => [name, value]
    f.sanitize_param { |params, rule|
      name, type, options = rule

      if valid
        [name, value]
      else
        Error.new("Invalid param #{name}")
      end
    }

    # [SinatraParams, [r]] => validated_params | Error
    f.sanitize_params { |params, rules|
      sanitizer = curry(sanitize_param_, params)
      sanitized_values = map(sanitizer, rules)
      reduce(_build_result_hash!, {}, sanitized_values)
    }

    fi._build_result_hash = typed(
      :default =>
        proc { |result_obj, result|
          name, value = result
          result_obj[name] = value },
      [Error, :default] => proc { |error, _| error },
      [Error, Error] => proc { |error, next_error| error.concat(next_error) } )
  end
end
