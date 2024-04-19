# frozen_string_literal: true

module Hpr
  # Repository model
  class Repository < ActiveRecord::Base
    enum status: %i[idle cloning fetching pushing]

    validates :name, :url, :mirror_url, :gitlab_project_id, :status, presence: true
  end
end
