require 'io/console'
task :move_coas do
  begin
    puts "Make sure that all msds and coas files have been copied to /public/uploads/coa_upload/msds_pdfs and /public/uploads/msds_uploads/coas_pdfs respectively"
    puts "Which user, press enter for app_chemtrack : press the spacebar for other user "
    username = default_user
    puts "password?"
    password = STDIN.noecho(&:gets).chomp
    puts "Which version of Chemtrack? : press enter for sbox_chemtrack_rruizvev or spacebar for other"
    chemtrack = default_chemtrack

    ActiveRecord::Base.establish_connection(
        :adapter => "mysql2",
        :host => "au.epa.gov",
        :username => "#{username}",
        :password => "#{password}",
    )
    connection = ActiveRecord::Base.connection
    connection.execute("
           TRUNCATE #{chemtrack}.coas")
    connection.execute("
           TRUNCATE #{chemtrack}.msds")
    puts "#{Dir.pwd}/public/uploads/coa_uploads/coa_pdfs"
    connection.execute("CREATE TEMPORARY TABLE #{chemtrack}.pdf_files(
                             barcode VARCHAR(50),
                             file_name VARCHAR(255),
                             file_url VARCHAR(255),
                             file_type VARCHAR(50));")


    puts "INSERTING files into tmp table"

    Dir.foreach("#{Dir.pwd}/public/uploads/coa_upload/coa_pdfs/") do |file_name|
      file_url = "/uploads/coa_upload/coa_pdfs"
      file_url << "/#{file_name}"
      barcode = regex(file_name)
      connection.execute("INSERT INTO #{chemtrack}.pdf_files (barcode, file_name, file_url, file_type)
                          VALUES ('#{barcode}', '#{file_name}', '#{file_url}', 'coa');")
      file_url.clear
    end

    Dir.foreach("#{Dir.pwd}/public/uploads/msds_upload/msds_pdfs/") do |file_name|
      file_url = "/uploads/msds_upload/msds_pdfs"
      file_url << "/#{file_name}"
      barcode = regex(file_name)
      connection.execute("INSERT INTO #{chemtrack}.pdf_files (barcode, file_name, file_url, file_type)
                          VALUES ('#{barcode}', '#{file_name}', '#{file_url}', 'msds');")
      file_url.clear
    end

    puts "Updating COA table in #{chemtrack}"

    connection.execute("INSERT INTO #{chemtrack}.coas (filename, file_url, user_id, coa_summary_id, created_at, updated_at, barcode)
                         SELECT pf.file_name, pf.file_url, '1', coa.id, now(), now(), coa.bottle_barcode
                         FROM #{chemtrack}.coa_summaries as coa
                         INNER JOIN #{chemtrack}.pdf_files as pf
                         ON pf.barcode = coa.bottle_barcode
                         WHERE pf.file_type = 'coa';")

    puts "Updating MSDS table in #{chemtrack}"

    connection.execute("INSERT INTO #{chemtrack}.msds (filename, file_url, user_id, coa_summary_id, created_at, updated_at, barcode)
                         SELECT pf.file_name, pf.file_url, '1', coa.id, now(), now(), coa.bottle_barcode
                         FROM #{chemtrack}.coa_summaries as coa
                         INNER JOIN #{chemtrack}.pdf_files as pf
                         ON pf.barcode = coa.bottle_barcode
                         WHERE pf.file_type = 'msds';")

  rescue Mysql2::Error => e #check for errors in database
    puts e.error
  ensure
     connection.execute("DROP TABLE #{chemtrack}.pdf_files;")
  end
end

def default_user
  c = read_char
  case c
    when "\r"
      return "app_chemtrack"
    when " "
      puts "which user?"
      STDIN.gets.chomp
    else
      raise "error"
  end
end

def default_chemtrack
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

def regex(file_name)
  regex = file_name.scan(/(^.*?)_/)
  if regex.count == 1
    barcode = regex[0][0]
  else
    barcode = "Not Found"
  end
end