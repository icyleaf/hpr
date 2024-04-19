# frozen_string_literal: true

require 'git'

module Git
  class Base
    def config(name = nil, *values, append: false)
      if name && values.size.positive?
        lib.config_set(name, *values, append: append)
      elsif name
        lib.config_get(name)
      else
        lib.config_list
      end
    end
  end

  class Lib
    def config_set(name, *values, append: false)
      command('config', _config_set_args(name, values.pop, append: append))

      values.each do |value|
        command('config', _config_set_args(name, value, append: true))
      end
    end

    private

    def _config_set_args(name, value, append: false)
      [].tap do |obj|
        obj << '--add' if append
        obj << name << value
      end
    end
  end
end
