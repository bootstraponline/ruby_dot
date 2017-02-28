module A
  module ::B
  end
end

module C
  module ::D
    module E

    end
  end
end

# A
# B
# C
# D::E
