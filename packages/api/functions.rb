require_package 'fdsl/fdsl'

module API
  Functions = FDSL.create do |f|
    # [SinatraParams, [r]] => validated_params | APIFail
    f.sanitize { |params, rules|
      sanitizer = curry(sanitize_param_, params)
      sanitized_values = map(sanitizer, rules)
      reduce(_build_result_hash!, {}, sanitized_values)
    }

    # [SinatraParams, [rule_spec]] => [name, value]
    f.sanitize_param { |params, rule|
      name, type, options = rule

      raise "Invalid param #{name}" unless valid

      [name, value]
    }

    f._build_result_hash! = typed(
      :default => proc { |result_obj, result|
                    name, value = result
                    result_obj[name] = value }
      Fail => typed(
        :default => proc { |fail_obj, result| fail_obj }
        Fail => proc { |fail_obj, new_fail| fail_obj.append(new_fail) } )
    )
  end
end
