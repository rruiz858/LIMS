require 'io/console'
affected_tables = %w(

        activities addresses bottles btl_comits coas coa_summaries coa_summary_files
        coa_uploads comits controls mentor_postdocs msds msds_uploads
        order_chemical_lists order_concentrations order_plate_details orders order_statuses plate_details plates
        roles samples shipment_files shipments_activities task_orders tox_21_chemicals users
        users_task_orders vendors vial_details
    )

task :legacy_ct156 do
  puts "This rake task handles the import of legacy information back into the staging development after migrations have been completed in staging"
  puts "Have you done a rake db:migrate in the staging/production environment with the latest schema changes and have you run a rake copy? Yes or No"
  answer = STDIN.gets.chomp
  if answer.downcase == 'yes'
    puts "which user, press enter for app_chemtrack_s, press the spacebar for other user "
    username = default_user
    puts "password?"
    password = STDIN.noecho(&:gets).chomp
    puts "Version of Chemtrack copying from, press enter for sbox_chemtrack_rruizvev, press spacebar for other"
    legacy_schema = default_legacy
    puts "Version of Chemtrack copying to **Note this schema will be truncated/updated with Legacy-Chemtrack data from #{legacy_schema}, press enter for sbox_chemtrack or spacebar for other"
    staging_schema = default_staging
    begin
      ActiveRecord::Base.establish_connection(
          :adapter => "mysql2",
          :host => "au.epa.gov",
          :username => "#{username}",
          :password => "#{password}",
      )
      connection = ActiveRecord::Base.connection
      puts "#######################"
      puts "The Rake task has begun"
      puts "#######################"

      foreign_checks = [
          'SET foreign_key_checks = 0;',
          'SET SQL_SAFE_UPDATES = 0; '
      ]
      foreign_checks.each do |statement|
        connection.execute(statement)
      end

      affected_tables.each do |i|
        temp_array= Array.new
        staging_table = staging_schema+'.'+ i
        legacy_table = legacy_schema+'.'+i
        connection.execute("TRUNCATE #{staging_table};")
        headers= connection.execute("SELECT column_name from information_schema.columns where table_schema='#{staging_schema}'
        AND table_name= '#{i}';")
        headers.each do |key, value|
          temp_array.push(key)
        end
        puts "populating #{staging_table}"
        connection.execute("INSERT INTO #{staging_table} (#{temp_array.join(',')}) SELECT #{temp_array.join(',')} FROM #{legacy_table};")
      end

      foreign_checks_on = [
          'SET foreign_key_checks = 1;',
          'SET SQL_SAFE_UPDATES = 1; '
      ]
      foreign_checks_on.each do |statement|
        connection.execute(statement)
      end
    rescue Mysql2::Error => e #check for errors in database
      puts e.error
    ensure
      connection.close
    end
    puts "Rake task complete "
  else
    puts "run a rake:db:migrate or a rake copy then proceed with rake task "


  end
end


def default_staging
  c = read_char
  case c
    when "\r"
      return "stg_chemtrack"
    when " "
      puts "which version?"
      STDIN.gets.chomp
    else
      raise "error"

  end
end


def default_legacy
  c = read_char
  case c
    when "\r"
      return "sbox_chemtrack_rruizvev"
    when " "
      puts "which version?"
      STDIN.gets.chomp
    else
      raise "error"
  end
end
#
def default_user
  c = read_char
  case c
    when "\r"
      return "app_chemtrack_s"
    when " "
      puts "which user?"
      STDIN.gets.chomp
    else
      raise "error"
  end
end


def read_char
  STDIN.echo = false
  STDIN.raw!

  input = STDIN.getc.chr
  if input == "\e" then
    input << STDIN.read_nonblock(3) rescue nil
    input << STDIN.read_nonblock(2) rescue nil
  end
ensure
  STDIN.echo = true
  STDIN.cooked!

  return input
end
