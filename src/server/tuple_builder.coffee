_ = require "underscore"
{ Util, CompositeTuple } = require("./core")
{ Inflection, visit } = Util
{ camelize } = Inflection

visitProperty = (name) ->
  (r, rows) ->
    @visit(r[name], rows)

module.exports =
  visit: visit

  visit_Relations_Table: (r, rows) ->
    return [] if rows.length == 0
    alias = getAliasFor(this, r)
    nameMap = buildFieldNameMap(rows[0], alias)
    new r.recordClass(mapFieldNames(row, nameMap)) for row in rows

  visit_Relations_Alias: (r, rows) ->
    @visit_Relations_Table(r, rows)

  visit_Relations_InnerJoin: (r, rows) ->
    leftRecords = @visit(r.left, rows)
    rightRecords = @visit(r.right, rows)
    for leftRecord, i in leftRecords
      new CompositeTuple(leftRecord, rightRecords[i])

  visit_Relations_Limit: visitProperty('operand')
  visit_Relations_Offset: visitProperty('operand')
  visit_Relations_OrderBy: visitProperty('operand')
  visit_Relations_Selection: visitProperty('operand')
  visit_Relations_Union: visitProperty('left')
  visit_Relations_Difference: visitProperty('left')
  visit_Relations_Projection: visitProperty('table')

buildFieldNameMap = (row, thisTableName) ->
  nameMap = {}
  for qualifiedColumnName of row
    [tableName, columnName] = qualifiedColumnName.split("__")
    if (tableName is thisTableName)
      nameMap[camelize(columnName)] = qualifiedColumnName
  nameMap

mapFieldNames = (row, nameMap) ->
  fieldValues = {}
  for fieldName, qualifiedColumnName of nameMap
    fieldValues[fieldName] = row[qualifiedColumnName]
  fieldValues

getAliasFor = (self, table) ->
  tableName = table.resourceName()
  aliasesForTable(self, tableName)[table.alias] ?= nextAliasFor(self, tableName)

nextAliasFor = (self, tableName) ->
  index = _.size(aliasesForTable(self, tableName))
  suffix = if (index > 0) then (index + 1) else ""
  "#{tableName}#{suffix}"

aliasesForTable = (self, tableName) ->
  self.aliasesByTableAndAlias ?= {}
  self.aliasesByTableAndAlias[tableName] ?= {}

