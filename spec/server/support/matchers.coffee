_ = require "underscore"

_.extend exports,
  toBeA: (constructor) ->
    @message = -> [
      "Expected #{@actual} to be an instance of #{constructor.name}."
      "Expected #{@actual} not to be an instance of #{constructor.name}."
    ]
    @actual instanceof constructor

  toBeLikeQuery: (expectedSql, expectedLiterals=[]) ->
    unless @actual?.length >= 2
      @message = -> "Expected an array of [sql, literals], got #{@actual}"
      return false
    [actualSql, actualLiterals] = @actual
    actualSql = normalizeSql(actualSql)
    expectedSql = normalizeSql(expectedSql)

    @message = -> [
      """
        Expected this query:
        '#{expectedSql}', [#{expectedLiterals}]

        but got this query:
        '#{actualSql}', [#{actualLiterals}]
      """,
      """
        Expected two different queries. Both were like this:
        '#{actualSql}', [#{actualLiterals}]
      """,
    ]
    _.isEqual([actualSql, actualLiterals], [expectedSql, expectedLiterals])

  toEqualRecords: (recordClass, attrHashes) ->
    if message = recordArrayMatcherMessage(@actual, attrHashes.length)
      @message = -> message
      return false
    for record, i in @actual
      if message = recordMatcherMessage(record, recordClass, attrHashes[i])
        @message = -> message
        return false
    true

  toEqualRecord: (recordClass, attrs) ->
    if message = recordMatcherMessage(@actual, recordClass, attrs)
      @message = -> message
      false
    else
      true

  toEqualCompositeTuples: (leftClass, leftAttrHashes, rightClass, rightAttrHashes) ->
    if (rightAttrHashes.length isnt leftAttrHashes.length)
      throw new Error("Test error - non-matching number of rows")
    if message = recordArrayMatcherMessage(@actual, leftAttrHashes.length)
      @message = -> message
      return false
    for tuple, i in @actual
      { left, right } = tuple
      if message = recordMatcherMessage(left, leftClass, leftAttrHashes[i])
        @message = -> message
        return false
      if message = recordMatcherMessage(right, rightClass, rightAttrHashes[i])
        @message = -> message
        return false
    true

recordArrayMatcherMessage = (records, n) ->
  unless records
    return "Expected an array of records. Got #{records}."
  unless (records.length == n)
    return """
      Expected this: #{records}
      to contain #{n} tuples, not #{records.length}.
    """

recordMatcherMessage = (record, recordClass, attrs) ->
  unless record instanceof recordClass
    return """
      Expected an instance of #{recordClass.name},
      but got this: #{record}.
    """
  unless isHashSubset(attrs, record.fieldValues())
    return """
      Expected this record: #{record}
      to have these attributes: #{JSON.stringify(attrs)}
    """

isHashSubset = (subhash, hash) ->
  for key, value of subhash
    return false unless value == hash[key]
  true

normalizeSql = (string) ->
  string
    .replace(/\s+/g, ' ')
    .replace(/\(\s+/g, '(')
    .replace(/\s+\)/g, ')')
    .replace(/\s$/g, '')
    .replace(/^\s/g, '')
