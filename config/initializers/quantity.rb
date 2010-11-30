require 'quantity/all'
Quantity::Unit.add_unit :day, :time, 86_400_000, :days
Quantity::Unit.add_unit :month, :time, 2_592_000_000, :months
Quantity::Unit.add_unit :year, :time, 31_536_000_000, :years
