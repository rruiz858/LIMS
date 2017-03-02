if Rails.env.development?
  env = "development"
elsif Rails.env.production?
  env = "production"
end

task :delay_job_start do
 sh "RAILS_ENV=#{env} bundle exec bin/delayed_job start"
end

task :delay_job_stop do
  sh "RAILS_ENV=#{env} bundle exec bin/delayed_job stop"
end