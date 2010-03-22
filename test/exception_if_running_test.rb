# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'exception_if_running'

class ExceptionIfRunningTest < Test::Unit::TestCase
  class A
    include ExceptionIfRunning
    def m
      "m"
    end
    
    def m2
      "m2"
    end

    attr_accessor :m3
    exception_if_running :m, :m2, :m3=
  end

  def test_exception_if_running
    a = A.new
    a.m3 = "m3"
    assert_equal("m",  a.m)
    assert_equal("m2", a.m2)
    assert_equal("m3", a.m3)

    a.instance_variable_set("@running", true)
    assert_raise(ExceptionIfRunning::IllegalStateException){ a.m }
    assert_raise(ExceptionIfRunning::IllegalStateException){ a.m2 }
    assert_raise(ExceptionIfRunning::IllegalStateException){ a.m3 = "val" }

    a.instance_variable_set("@running", false)
    assert_equal("m",  a.m)
    assert_equal("m2", a.m2)
    assert_equal("m3", a.m3)
    assert_equal("val", a.m3 = "val")
  end
end
