# TODO

- parameterized queries

- relational operations
  - selections outside of limits, offsets, orderings
  - Table#alias (allow same table to appear on both sides of a join)
  - aggregation
    - group by sql
    - in-memory grouping on client-side
    - aggregation functions: sum, min, max, count, avg

- Record
  - make association methods work server-side
  - validations

- sandbox
  - separate exposed tables for different CRUD ops
  - do record validation

- identity map

- support mysql and sqlite
  - connection adapters
  - alternative SQL generation
