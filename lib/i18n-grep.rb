module I18n
  class << self
    def grep(pattern, files)
      results = []

      files.each do |filepath|
        File.open(filepath) do |file|
          key_stack = []
          prev_indent = 0
          indent_spaces = nil
          file.each_with_index do |line, index|
            line = line.chomp
            line_number = index + 1
            next unless line =~ /\s*\w+:/

            key = line[/\w+:/].sub(':', '')
            word = line.gsub(/.*:\s*/, '')

            indent = (line =~ /\w/)
            if indent_spaces.nil? && indent > 0
              indent_spaces = indent
            end
            indent /= indent_spaces if indent > 0

            unless indent == prev_indent
              if indent < prev_indent
                (prev_indent - indent + 1).times { key_stack.pop }
              end
            else
              key_stack.pop
            end
            key_stack.push(key)
            prev_indent = indent

            joined_key = key_stack.join('.')
            if joined_key =~ /#{pattern}/
              results << [filepath, line_number, joined_key, word]
            end
          end
        end
      end

      results
    end
  end
end