module Jobs
  class ReplicationLag
    ALLOWED_LAG_IN_SECONDS = 120

    def start
      loop do
        lag_in_seconds = replication_lag
        return if lag_in_seconds <= ALLOWED_LAG_IN_SECONDS

        notify("Replication lag #{lag_in_seconds} sec")
        sleep 90
      end
    end

    private

    def replication_lag
      str_time = %x(docker exec #{config["container_name"]} psql -U #{config["db_user"]} -A -t -c "select now() - pg_last_xact_replay_timestamp();")
      lag_in_secods = Time.parse(str_time, beginning_of_the_day) - beginning_of_the_day
    end

    def beginning_of_the_day
      current_time = Time.new
      Time.parse "#{current_time.year}-#{current_time.month}-#{current_time.day}"
    end
  end
end
