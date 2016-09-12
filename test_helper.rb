def require_package(name)
  require_relative 'packages/' + name
end

require 'minitest/autorun'
