module RubyDot
  class Render

    DRAW_IO = File.join(__dir__, 'template', 'draw_io.xml.mustache')

    def draw_io_xml hash
      file_array = []

      id = 1
      x = 10
      y = 10
      width = 120
      _height = 60

      space_x = x + width/2.0

      hash.each do |key, value|
        file_name = key
        modules   = Array(value[:modules])
        classes   = Array(value[:classes])

        # value is rendered without escaping using {{{ }}} in the mustache template

        file_description = [modules + classes]
        file_array << {
            id: id+=1,
            value: "&lt;b&gt;#{file_name}&lt;/b&gt;&lt;div&gt;#{file_description.join "\n"}&lt;/div&gt;",
            x: id * space_x,
            y: y
        }

        id += 1
      end

      Mustache.render File.read(DRAW_IO), file_array: file_array
    end
  end
end
