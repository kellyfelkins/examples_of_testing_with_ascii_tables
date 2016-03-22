describe "Examples" do

  # Simple example of single variable and expected result.
  describe '#clean_subject' do
    it "handles these cases" do
      cases_as_table = <<TEXT
|---------------------------------------+-------------------------------|
| subject                               | expected                      |
|---------------------------------------+-------------------------------|
| have you seen my dog                  | have you seen my dog          |
|---------------------------------------+-------------------------------|
| Re: [JMN test] re: Armed robbery on   | Armed robbery on Excelsior    |
| Excelsior Ave Sunday evening          | Ave Sunday evening            |
|---------------------------------------+-------------------------------|
| [JMN] re: Pedestrian Hit on Park Blvd | Pedestrian Hit on Park        |
| 1-21-2015                             | Blvd 1-21-2015                |
|---------------------------------------+-------------------------------|
| FW: [JMN test] re: Comcast lots of    | Comcast lots of downtime/luck |
| downtime/luck with service calls?     | with service calls?           |
|---------------------------------------+-------------------------------|
TEXT
      ATV.from_string(cases_as_table).each do |row|
        subject = row['subject']
        expected = row['expected']
        expect(InboundMailParsers::Base.new({}).clean_subject(subject)).to eq(expected)
      end
    end
  end

  # Table includes both setup and expected results.
  # Uses :aggregate_failures so that all assertions are run
  # even when one fails.
  # Include file and line number with failure messages.
  describe "#time_left_string", :aggregate_failures do
    it 'when ends_at defined, formats time like this' do
      mumble = FactoryGirl.build(:mumble, ends_at: Time.local(2014, 7, 14))
      test_data, line_no = <<EOD, __LINE__ + 4
|-----------+-------+----------------------------------|
| delta-end | html? | expected                         |
|-----------+-------+----------------------------------|
| +1.day    |       | No time left                     |
|-----------+-------+----------------------------------|
| +1.day    | true  | <em>No</em>&nbsp;time&nbsp;left  |
|-----------+-------+----------------------------------|
| -9.hours  |       | 9 hours left                     |
|-----------+-------+----------------------------------|
| -9.hours  | true  | <em>9</em>&nbsp;hours&nbsp;left  |
|-----------+-------+----------------------------------|
| -28.hours |       | 28 hours left                    |
|-----------+-------+----------------------------------|
| -28.hours | true  | <em>28</em>&nbsp;hours&nbsp;left |
|-----------+-------+----------------------------------|
| -11.days  |       | 11 days left                     |
|-----------+-------+----------------------------------|
| -11.days  | true  | <em>11</em>&nbsp;days&nbsp;left  |
|-----------+-------+----------------------------------|
EOD

      ATV.from_string(test_data).each_with_index do |row, index|
        options = row['html?'] ? :html : nil
        Timecop.freeze(mumble.ends_at + eval(row['delta-end'])) do
          time_left_string = helper.time_left_string(mumble, options)
          expect(time_left_string).to eq(row['expected']),
                                      %Q|expected "#{row['expected']}", got "#{time_left_string}" |+
                                        %Q|\nat #{__FILE__}:#{line_no+(index * 2)}|

        end
      end
    end
  end

  # The class being tested has a command interface and the test
  # sometimes executes multiple commands before checking the state.
  # The table in this example includes the name of the test so that
  # useful error messages can be generated.
  # The limit, balance, valid? and summarize columns contain expected
  # results for those methods - so multiple methods are being tested.
  # Note that the number of lines in each row is kept constant at 3 so
  # that the error line number can be calculated.
  describe 'commands and results' do
    it 'sets the account attributes appropriately' do
      test_data, line_no = <<EOD, __LINE__ + 4
|--------------------+------------------------------------+--------+-------+---------+--------+---------------|
| test               | commands                           | name   | limit | balance | valid? | summarize     |
|--------------------+------------------------------------+--------+-------+---------+--------+---------------|
| valid cc_number    | add Tom 4111111111111111 $1000     | Tom    |  1000 |       0 | true   | Tom: $0       |
|                    |                                    |        |       |         |        |               |
|                    |                                    |        |       |         |        |               |
|--------------------+------------------------------------+--------+-------+---------+--------+---------------|
| invalid cc_number  | add Quincy 1234567890123456 $2000  | Quincy |  2000 |       0 | false  | Quincy: error |
|                    |                                    |        |       |         |        |               |
|                    |                                    |        |       |         |        |               |
|--------------------+------------------------------------+--------+-------+---------+--------+---------------|
| charge under limit | add Tom 4111111111111111 $1000,    | Tom    |  1000 |     500 | true   | Tom: $500     |
|                    | charge Tom $500                    |        |       |         |        |               |
|                    |                                    |        |       |         |        |               |
|--------------------+------------------------------------+--------+-------+---------+--------+---------------|
| charge over limit  | add Tom 4111111111111111 $1000,    | Tom    |  1000 |       0 | true   | Tom: $0       |
|                    | charge Tom $5000                   |        |       |         |        |               |
|                    |                                    |        |       |         |        |               |
|--------------------+------------------------------------+--------+-------+---------+--------+---------------|
| charge to invalid  | add Quincy 1234567890123456 $2000, | Quincy |  2000 |       0 | false  | Quincy: error |
| cc_number          | charge Quincy $500                 |        |       |         |        |               |
|                    |                                    |        |       |         |        |               |
|--------------------+------------------------------------+--------+-------+---------+--------+---------------|
| credit             | add Lisa 5454545454545454 $3000,   | Lisa   |  3000 |     -93 | true   | Lisa: $-93    |
|                    | charge Lisa $7,                    |        |       |         |        |               |
|                    | credit Lisa $100                   |        |       |         |        |               |
|--------------------+------------------------------------+--------+-------+---------+--------+---------------|
| credit to invalid  | add Quincy 1234567890123456 $2000, | Quincy |  2000 |       0 | false  | Quincy: error |
| cc_number          | credit Quincy $100                 |        |       |         |        |               |
|                    |                                    |        |       |         |        |               |
|--------------------+------------------------------------+--------+-------+---------+--------+---------------|
EOD
      ATV.from_string(test_data).each_with_index do |row, index|
        cc_processor = CcProcessor.new
        test = row.delete('test').last
        cmds = row.delete('commands').last.split ','
        cmds.each do |cmd_string|
          cmd, *args = cmd_string.split ' '
          cc_processor.send cmd, *args
        end

        name = row['name']
        cc_processor.accounts.keys.must_equal([name])
        account = cc_processor.accounts[name]
        row.each do |attribute, expected|
          expected = expected.to_i if %w|limit balance|.include? attribute
          actual = account.send(attribute)
          actual.must_equal expected, %Q|Unexpected "#{attribute}" for #{test} test at #{__FILE__}:#{line_no+(index * 4)}|
        end
      end
    end
  end
end