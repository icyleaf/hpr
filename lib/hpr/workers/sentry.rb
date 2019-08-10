# frozen_string_literal: true

module Hpr
  # Repost exception to sentry worker
  class SentryWorker
    include Sidekiq::Worker

    def perform(event)
      Raven.send_event(event)
    end
  end
end
