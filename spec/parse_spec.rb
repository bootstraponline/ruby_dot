require_relative 'spec_helper'

describe 'parse' do
  def module_fail int=''
    path = File.join(__dir__, "fixture/module_fail#{int}.rb")
    raise "File does not exist: #{path}" unless File.exist? path
    path
  end

  it 'parses modules correctly 1' do
    class_map = RubyDot::Main.new.run module_fail 1

    expect(class_map).to eq({ 'module_fail1.rb' => {
        :modules =>
            ['A::B::C',
             'E',
             'F',
             'G',
             'H::I::J'] } })
  end


  it 'parses modules correctly 2' do
    class_map = RubyDot::Main.new.run module_fail 2

    expect(class_map).to eq({ 'module_fail2.rb' =>
                                  { :classes => ['K::L'],
                                    :modules => ['A::B::C',
                                                 'E',
                                                 'F',
                                                 'G',
                                                 'H::I::J',
                                                 'M::N::O::P::Q'] } })
  end

  it 'parses modules correctly 3' do
    class_map = RubyDot::Main.new.run module_fail 3

    expect(class_map).to eq(
                             { 'module_fail3.rb' =>
                                   { :modules =>
                                         ['M::N::O::P::Q'] } }
                         )
  end

  it 'parses modules correctly 4' do
    class_map = RubyDot::Main.new.run module_fail 4

    # A::B::C
    # A::B::D
    # A::E::F

    expect(class_map).to eq(
                             { 'module_fail4.rb' => {
                                 :modules =>
                                     ['A::B::C',
                                      'A::B::D',
                                      'A::E::F'] } }
                         )
  end

  it 'parses modules correctly 5' do
    class_map = RubyDot::Main.new.run module_fail 5

#    puts JSON.pretty_generate(class_map)

    expect(class_map).to eq(
                             { "module_fail5.rb" => { :modules =>
                                                          ["A::B",
                                                           "A::C",
                                                           "A::D"] } }
                         )
  end

  it 'parses modules correctly 6' do
    class_map = RubyDot::Main.new.run module_fail 6
    # module A
    #   module B
    #   module C
    #
    # A::B
    # A::C
    expect(class_map).to eq(
                             { 'module_fail6.rb' =>
                                   { :modules => ['A',
                                                  'B',
                                                  'C',
                                                  'D'] } }
                         )
  end

  it 'parses modules correctly 7' do
    class_map = RubyDot::Main.new.run module_fail 7

    expect(class_map).to eq({
                                'module_fail7.rb' =>
                                 {:modules=>['A::B1::C1::D1::E1',
                                             'A::B2::C2::D2',
                                             'A::B3::C3',
                                             'A::B4'] }})

    # A::B1::C1::D1::E1
    # A::B2::C2::D2
    # A::B3:C3
    # A::B4
  end
end
