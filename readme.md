# DB

Provides event-driven asynchronous drivers for various database adaptors, including [Postgres](https://github.com/socketry/db-postgres) and [MariaDB/MySQL](https://github.com/socketry/db-mariadb).

[![Development Status](https://github.com/socketry/db/workflows/Test/badge.svg)](https://github.com/socketry/db/actions?workflow=Test)

## Features

  - Event driven I/O for streaming queries and results.
  - Standard interface for multiple database adapters.

## Usage

Please see the [project documentation](https://socketry.github.io/db/) for more details.

  - [Getting Started](https://socketry.github.io/db/guides/getting-started/index) - This guide explains how to use `db` for database queries.

  - [Executing Queries](https://socketry.github.io/db/guides/executing-queries/index) - This guide explains how to escape and execute queries.

  - [Example Queries](https://socketry.github.io/db/guides/example-queries/index) - This guide shows a variety of example queries using the DB gem.

  - [Data Types](https://socketry.github.io/db/guides/datatypes/index) - This guide explains about SQL data types, and how they are used by the DB gem.

## Releases

Please see the [project releases](https://socketry.github.io/db/releases/index) for all releases.

### v0.14.0

  - Introduce `DB::Features` for feature detection.

### v0.13.0

  - Add agent context.

## See Also

  - [db-postgres](https://github.com/socketry/db-postgres) - Postgres adapter for the DB gem.
  - [db-mariadb](https://github.com/socketry/db-mariadb) - MariaDB/MySQL adapter for the DB gem.
  - [db-model](https://github.com/socketry/db-model) - A simple object relational mapper (ORM) for the DB gem.
  - [db-migrate](https://github.com/socketry/db-migrate) - Database migration tooling for the DB gem.
  - [db-active\_record](https://github.com/socketry/db-active_record) - An ActiveRecord adapter for the DB gem.

## Contributing

We welcome contributions to this project.

1.  Fork it.
2.  Create your feature branch (`git checkout -b my-new-feature`).
3.  Commit your changes (`git commit -am 'Add some feature'`).
4.  Push to the branch (`git push origin my-new-feature`).
5.  Create new Pull Request.

### Developer Certificate of Origin

In order to protect users of this project, we require all contributors to comply with the [Developer Certificate of Origin](https://developercertificate.org/). This ensures that all contributions are properly licensed and attributed.

### Community Guidelines

This project is best served by a collaborative and respectful environment. Treat each other professionally, respect differing viewpoints, and engage constructively. Harassment, discrimination, or harmful behavior is not tolerated. Communicate clearly, listen actively, and support one another. If any issues arise, please inform the project maintainers.
