desc 'Replays payload recorded with rake cfe:record_payloads on apply - Expects server to  be running on port 4000 - Expects YAML file in  tmp/api_replay.yml'
task replay: :environment do
  require_relative '../task_helpers/payload_player'
  PayloadPlayer.call
end
