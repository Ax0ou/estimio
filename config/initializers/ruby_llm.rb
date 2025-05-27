require "ruby_llm"

RubyLLM.configure do |config|
  # Ta clé OpenAI
  config.openai_api_key = ENV.fetch("OPENAI_API_KEY")
end
