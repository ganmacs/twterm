module Twterm
  class Tweetbox
    include Singleton
    include Readline
    include Curses

    def initialize
      @status = ''
    end

    def compose(in_reply_to = nil)
      if in_reply_to.is_a? Status
        @in_reply_to = in_reply_to
      else
        @in_reply_to = nil
      end

      resetter = proc do
        reset_prog_mode
        sleep 0.1
        Screen.instance.refresh
      end

      thread = Thread.new do
        close_screen

        if @in_reply_to.nil?
          puts "\nCompose new tweet:"
        else
          puts "\nReply to @#{@in_reply_to.user.screen_name}'s tweet: \"#{@in_reply_to.text}\""
        end

        CompletionManager.instance.set_default_mode!

        loop do
          loop do
            msg = @in_reply_to.nil? || !@status.empty? ? '> ' : "> @#{in_reply_to.user.screen_name} "
            line = (readline(msg, true) || '').strip
            break if line.empty?

            if line.end_with?('\\')
              @status << line.chop.lstrip + "\n"
            else
              @status << line
              break
            end
          end

          puts "\n"

          case validate
          when :too_long
            puts "Status is too long (#{length} / 140 characters)"
          when :invalid_characters
            puts 'Status contains invalid characters'
          else
            break
          end

          puts "\n"
          clear
        end

        resetter.call
        post
      end

      App.instance.register_interruption_handler do
        thread.kill
        clear
        puts "\ncanceled"
        resetter.call
      end

      thread.join
    end

    def post
      return if validate

      Client.current.post(@status, @in_reply_to)
      clear
    end

    def validate
      Twitter::Validation.tweet_invalid?(@status)
    end

    def length
      Twitter::Validation.tweet_length(@status)
    end

    def clear
      @status = ''
    end
  end
end
