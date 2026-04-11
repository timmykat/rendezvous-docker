module Email
  class MessageTopics
    TOPICS = {
      ask_a_question: 'Ask a question',
      help: 'Help!',
      request_change: 'Request a change'
    }.freeze

    def self.all
      TOPICS
    end

    def self.options_for_select
      TOPICS.map { |k, v| [v, k] }
    end

    def self.label(key)
      TOPICS[key.to_sym]
    end
  end
end
