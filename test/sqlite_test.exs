defmodule SqliteCDRTest do
  use ExUnit.Case, async: true

  alias ExCdrPusher.HSqlite


  setup_all do
    # Test Database must use import_sqlite.sql to define his schema and data
    {:ok, db} = Sqlitex.open('./data/freeswitchcdr-test.db')
    on_exit fn ->
      Sqlitex.close(db)
    end
    # {:ok, testsqlite_db: TestDatabase.init(db)}
    {:ok, testsqlite_db: db}
  end

  test "a basic query returns a list of CDRs", context do
    {:ok, [row]} = context[:testsqlite_db] |>
      Sqlitex.query("SELECT * FROM cdr LIMIT 1")
    assert row[:caller_id_name] == "0034650780000"
    # Fetch 2 records
    {:ok, rows} = context[:testsqlite_db] |>
      Sqlitex.query("SELECT * FROM cdr LIMIT 2")
    assert length(rows) == 2
    # assert row == [id: 1, name: "Mikey",
    #   created_at: {{2012,10,14},{05,46,28,318107}},
    #   updated_at: {{2013,09,06},{22,29,36,610911}}, type: nil]
  end

  test "test sqlite_get_cdr return cdrs", context do
    context[:testsqlite_db] |>
      Sqlitex.query(
        "INSERT INTO cdr VALUES (
          'Outbound Call','0034650780000','0034650780000','default',
          '2016-09-20 10:14:37', '2016-09-20 10:14:48',
          '2016-09-20 10:15:00', 23, 12, 'NORMAL_CLEARING',
          'eb43ce0a-bd20-46aa-ba14-9a22d6d0193c', '', '', 1, 1681, '0.020000',
          6, '0034650780000', 'MACHINE', '1', 16, 1, '', 0, 0);"
      )
    {:ok, cdr_list} = HSqlite.fetch_cdr()
    assert length(cdr_list) == 1

    HSqlite.mark_cdr_imported(cdr_list)
    {:ok, cdr_list} = HSqlite.fetch_cdr()
    assert length(cdr_list) == 0
  end

  test "get timestamp", context do
    {:ok, [row]} = context[:testsqlite_db] |>
      Sqlitex.query("SELECT * FROM cdr LIMIT 1")
    assert row[:start_stamp] == {{2016, 9, 20}, {6, 20, 13, 0}}
  end

end