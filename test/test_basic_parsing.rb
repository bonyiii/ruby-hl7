# $Id$
$: << '../lib'
require 'test/unit'
require 'ruby-hl7'

class BasicParsing < Test::Unit::TestCase
  def setup
    @simple_msh_txt = open( './test_data/test.hl7' ).readlines.first
    @base_msh = "MSH|^~\\&|LAB1||DESTINATION||19910127105114||ORU^R03|LAB1003929"
  end

  def test_simple_msh
    msg = HL7::Message.new
    msg.parse @simple_msh_txt
    assert_equal( @simple_msh_txt, msg.to_hl7 )
  end

  def test_class_parse
    msg = HL7::Message.parse( @simple_msh_txt )
    assert_equal( @simple_msh_txt, msg.to_hl7 )
  end

  def test_not_string_or_enumerable
    assert_raise( HL7::ParseError ) do
      msg = HL7::Message.parse( :MSHthis_shouldnt_parse_at_all )
    end
  end

  def test_message_to_string
    msg = HL7::Message.new
    msg.parse @simple_msh_txt
    orig = @simple_msh_txt.gsub( /\r/, '\n' )
    assert_equal( orig, msg.to_s )
  end

  def test_segment_numeric_accessor
    msg = HL7::Message.new
    msg.parse @simple_msh_txt
    assert_equal( @base_msh, msg[0].to_s ) 
  end

  def test_segment_string_accessor
    msg = HL7::Message.new
    msg.parse @simple_msh_txt
    assert_equal( @base_msh, msg["MSH"].to_s ) 
  end

  def test_segment_symbol_accessor
    msg = HL7::Message.new
    msg.parse @simple_msh_txt
    assert_equal( @base_msh, msg[:MSH].to_s ) 
  end

  def test_segment_numeric_mutator
    msg = HL7::Message.new
    msg.parse @simple_msh_txt
    inp = HL7::Message::Segment::Default.new
    msg[1] = inp
    assert_equal( inp, msg[1] )
  end

  def test_element_accessor
    msg = HL7::Message.new
    msg.parse @simple_msh_txt
    assert_equal( "LAB1", msg[:MSH].sending_app )
  end

  def test_element_mutator
    msg = HL7::Message.new
    msg.parse @simple_msh_txt
    msg[:MSH].sending_app = "TEST"
    assert_equal( "TEST", msg[:MSH].sending_app )
  end

  def test_element_missing_accessor
    msg = HL7::Message.new
    msg.parse @simple_msh_txt
    assert_raise( HL7::Exception, NoMethodError ) do
      msg[:MSH].does_not_really_exist_here
    end
  end

  def test_element_missing_mutator
    msg = HL7::Message.new
    msg.parse @simple_msh_txt
    assert_raise( HL7::Exception, NoMethodError ) do
      msg[:MSH].does_not_really_exist_here = "TEST"
    end
  end

  def test_segment_sort
    msg = HL7::Message.new
    pv1 = HL7::Message::Segment::PV1.new
    msg << pv1
    msh = HL7::Message::Segment::MSH.new
    msg << msh
    msh.sending_app = "TEST"
    

    initial = msg.to_s
    sorted = msg.sort
    final = sorted.to_s
    assert_not_equal( initial, final )
  end

end
