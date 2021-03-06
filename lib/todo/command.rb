# coding: utf-8

module Todo

  # コマンドラインベースの処理を行うクラス
  # @author tohrinagi
  class Command

    def self.run( argv )
      new(argv).execute
    end

    def initialize( argv )
      @argv = argv
    end

    def execute
      options = Options.parse!(@argv)
      sub_command = options.delete(:command)

      if sub_command == 'server'
        puts 'Start server process...'
        port_option = options[:port].nil? ? '' : "-p #{options[:port]}"
        host_option = options[:host].nil? ? '' : "-o #{options[:host]}"

        config = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config.ru'))
        exec "cd #{File.dirname(config)} && rackup -E  production #{port_option} #{host_option} #{config}"
      end

      DB.prepare

      tasks = case sub_command
             when 'create'
               create_task( options[:name], options[:content] )
             when 'delete'
               delete_task( options[:id] )
             when 'update'
               update_task( options.delete(:id), options )
             when 'list'
               find_tasks( options[:status] )
             end
      display_tasks tasks

    rescue => e
      abort "Error: #{e.message}"
    end

    def create_task( name, content )
      # タスクが作成時のstatusはデフォルト値が使われNOT_YETになる
      Task.create!(name: name, content: content ).reload
    end

    def delete_task( id )
      task = Task.find(id)
      task.destroy
    end

    def update_task( id, attribute )
      if status_name = attribute[:status]
        attribute[:status] = Task::STATUS.fetch( status_name.upcase )
      end

      task = Task.find( id )
      task.update_attributes! attribute

      task.reload
    end

    def find_tasks( status_name )
      all_tasks = Task.order( 'created_at DESC' )

      if status_name
        status = Task::STATUS.fetch( status_name.upcase )
        all_tasks.status_is( status )
      else
        all_tasks
      end
    end

    private

    def display_tasks( tasks )
      header = display_format('ID', 'Name', 'Content', 'Status' )
      puts header
      puts '-' * header.size
      Array(tasks).each do |task|
        puts display_format(task.id, task.name, task.content, task.status_name)
      end
    end

    def display_format(id, name, content, status )
      name_length = 20 - full_width_count(name)
      content_length = 40 - full_width_count(content)
      [id.to_s.rjust(4), name.ljust(name_length), content.ljust(content_length), status.center(10)].join(' | ')
    end

    def full_width_count( string )
      string.each_char.select{ |char| !(/[ -~｡-ﾟ]/.match(char)) }.count
    end
  end
end
