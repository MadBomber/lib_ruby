# tasks/db_dump.rake
# source http://www.codeotaku.com/journal/2016-12/cool-things-about-rakefiles/

namespace :db do
  namespace :dump do
    task :users do
      @records = Users.all
    end

    task :posts do
      @records = Posts.all
    end

    task :updated_recently do
      @records = @records.where("updated_at > ?", 6.months.ago)
    end

    task :as_json do
      $stdout.write(@records.as_json)
    end

    task :as_xml do
      $stdout.write(@records.as_xml)
    end
  end # namespace :dump do
end # namespace :db do
