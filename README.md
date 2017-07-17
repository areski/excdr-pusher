# Push FreeSWITCH CDRs to PostgreSQL [![Build Status](https://travis-ci.org/areski/excdr-pusher.svg?branch=master)](https://travis-ci.org/areski/excdr_pusher_influxdb)


Collect and push CDRs from [FreeSWITCH](https://freeswitch.org/) Sqlite to PostgreSQL.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

1. Add `excdr_pusher` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:excdr_pusher, "~> 0.1.0"}]
    end
    ```

2. Ensure `excdr_pusher` is started before your application:

    ```elixir
    def application do
      [applications: [:excdr_pusher]]
    end
    ```

3. Create directory for logs:

    ```
    mkdir /var/log/excdr_pusher
    ```

4. Add host in your `/etc/hosts` eg:

    ```
    127.0.0.1     influxdb_host
    ```


## Compile & Build Release

1. Edit version in `mix.exs`


2. Compile:

    MIX_ENV=prod mix compile


3. Build release:

    MIX_ENV=prod mix release


## Run tests

You will need to install inotify-tools to use `mix test.watch`.
`mix test.watch` will automatically run your Elixir project's tests each
time you save a file (https://github.com/lpil/mix-test.watch)

You will need (inotify-tools)[https://github.com/rvoicilas/inotify-tools/wiki]
installed.


## Code linter

We use [Credo](https://github.com/rrrene/credo) as colinter

    mix credo


## Start on reboot

Add excdr_pusher to `systemd` on Debian 8.x:

    cp excdr_pusher.service /lib/systemd/system/excdr-pusher.service
    systemctl enable excdr-pusher.service
    systemctl daemon-reload
    systemctl restart excdr-pusher.service


## Todo

List of improvements and tasks,

- [ ] Repo.insert_all make genserver crash on error, so we need to find a way to capture error, and uncommit the sqlite CDRs that were fetched, this will ensure that on error we can do something, maybe flag the CDRs as errors for future checks
- [ ] use [conform](https://github.com/bitwalker/conform) to support config file
- [ ] install script to quickly deploy
- [ ] add inch_ex
- [ ] add credo - https://github.com/rrrene/credo
