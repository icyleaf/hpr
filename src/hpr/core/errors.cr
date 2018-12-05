module Hpr
  class Error < Exception; end

  class ClientError < Error; end

  class NotFoundGitError < ClientError; end

  class NotRoleError < ClientError; end

  class UnkownURIError < ClientError; end

  class RepositoryExistsError < ClientError; end

  class NotFoundRepositoryError < ClientError; end

  class APIError < Error; end

  class MissingSSHKeyError < APIError; end

  class NotFoundGitlabProjectError < APIError; end
end
