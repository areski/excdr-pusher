defmodule SqliteCDRTest do
  use ExUnit.Case, async: true

  alias ExCdrPusher.HSqlite


  setup_all do
    {:ok, db} = Sqlitex.open('./data/freeswitchcdr.db')
    on_exit fn ->
      Sqlitex.close(db)
    end
    # {:ok, testsqlite_db: TestDatabase.init(db)}
    {:ok, testsqlite_db: db}
  end

  test "a basic query returns a list of CDRs", context do
    {:ok, [row]} = context[:testsqlite_db] |> Sqlitex.query("SELECT * FROM cdr LIMIT 1")
    assert row[:caller_id_name] == "Outbound Call"
    # Fetch 2 records
    {:ok, rows} = context[:testsqlite_db] |> Sqlitex.query("SELECT * FROM cdr LIMIT 2")
    assert length(rows) == 2
    # assert row == [id: 1, name: "Mikey", created_at: {{2012,10,14},{05,46,28,318107}}, updated_at: {{2013,09,06},{22,29,36,610911}}, type: nil]
  end

  test "test sqlite_get_cdr return cdrs", context do
    {:ok, cdrs} = HSqlite.sqlite_get_cdr()
    assert length(cdrs) == 10
  end

  test "get timestamp", context do
    {:ok, [row]} = context[:testsqlite_db] |> Sqlitex.query("SELECT * FROM cdr LIMIT 1")
    assert row[:start_uepoch] == 1477478486443963
  end

end