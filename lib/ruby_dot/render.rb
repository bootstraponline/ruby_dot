module RubyDot
  class Render

    DRAW_IO = File.join(__dir__, 'template', 'draw_io.xml.mustache')

    def draw_io_xml hash
      file_array = []

      id     = 1
      width  = 180
      height = 60

      space_x = 10 + width
      space_y = 10 + height

      row_limit = 4
      row       = 0 # x
      column    = 0 # y

      hash.each do |key, value|
        file_name = key
        names   = Array(value[:names])

        if row >= row_limit
          row    = 0
          column += 1
        end

        # lay out the nodes in a 4x row grid
        #
        # x x x x
        # x x x x
        # x x x x
        x                = row * space_x
        y                = column * space_y

        # value is rendered without escaping using {{{ }}} in the mustache template
        file_description = names.join "\n"
        file_array << {
            id:     id+=1,
            value:  "&lt;b&gt;#{file_name}&lt;/b&gt;&lt;div&gt;#{file_description}&lt;/div&gt;",
            x:      x,
            y:      y,
            width:  width,
            height: height
        }

        id += 1
        row += 1
      end

      Mustache.render File.read(DRAW_IO), file_array: file_array
    end
  end
end
