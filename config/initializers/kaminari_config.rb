Kaminari.configure do |config|
  config.default_per_page = 25
  config.max_per_page = 100
  config.window = 2
  config.outer_window = 1
  config.left = 1
  config.right = 1
end
