# frozen_string_literal: true

module Hpr
  class Error < StandardError; end

  class ClientError < Error; end

  class NotFoundGitError < ClientError; end

  class NotRoleError < ClientError; end

  class UnkownURIError < ClientError; end

  class MissingSSHKeyError < ClientError; end

  class RepositoryExistsError < ClientError; end

  class NotFoundError < ClientError; end

  class NotFoundRepositoryError < NotFoundError; end

  class NotFoundGitlabProjectError < NotFoundError; end
end
