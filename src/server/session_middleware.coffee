defaultRepository = require "./default_repository"

module.exports = (options={}) ->
  key = options.key || 'monarch'
  (req, res, next) ->
    repository = defaultRepository.clone()
    req[key] = repository.recordClasses()
    next()
