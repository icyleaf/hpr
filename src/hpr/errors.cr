module Hpr
  class Error < Exception; end

  class NotRoleError < Error; end

  class MissingSSHKeyError < Error; end

  class RepositoryExistsError < Error; end
  class NotFoundRepositoryError < Error; end

  class UnkownURIError < Error; end
end
