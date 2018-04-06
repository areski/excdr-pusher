
File.exists?(Path.expand("~/.iex.exs")) && import_file("~/.iex.exs")

alias ExCdrPusher.HSqlite

{:ok, db} = Sqlitex.open('./data/freeswitchcdr-test.db')

# :debugger.start()
# :int.ni(Campaign.Starter)
# :int.break(Campaign.Starter, 54)
