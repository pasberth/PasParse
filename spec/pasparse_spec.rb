require 'spec_helper'
require 'stringio'

describe "#expect" do
  subject { PasParse::Lexer.new StringIO.new "expected" }
  
  example do
    subject.expect!('expected').should == 'expected'
    subject.instance_eval { @input.read }.should == ''
  end

  example do
    subject.expect!('else').should be_nil
    subject.instance_eval { @input.read }.should == 'expected'
  end
  
  example do
    expect { subject.expect('expected') }.should_not raise_error PasParse::Unexpected
    subject.instance_eval { @input.read }.should == ''
  end
  
  example do
    expect { subject.expect('else') }.should raise_error PasParse::Unexpected
    subject.instance_eval { @input.read }.should == "expected"
  end
  
  example do
    subject.expect('expected').should == "expected"
    subject.instance_eval { @input.read }.should == ''
  end
end

describe "#touch" do
  subject { PasParse::Lexer.new StringIO.new "expected" }

  example do
    subject.touch!('expected').should == 'expected'
    subject.instance_eval { @input.read }.should == 'expected'
  end

  example do
    subject.touch!('else').should be_nil
    subject.instance_eval { @input.read }.should == 'expected'
  end
  
  example do
    expect { subject.touch('expected') }.should_not raise_error PasParse::Unexpected
    subject.instance_eval { @input.read }.should == 'expected'
  end
  
  example do
    expect { subject.touch('else') }.should raise_error PasParse::Unexpected
    subject.instance_eval { @input.read }.should == "expected"
  end
  
  example do
    subject.touch('expected').should == "expected"
    subject.instance_eval { @input.read }.should == 'expected'
  end
end

describe "#many" do
  subject { PasParse::Lexer.new StringIO.new 'ruby lisp haskell'}
  
  example do
    subject.many do
      lang = subject.many1(/\w/).join
      subject.many ' '
      lang
    end.should == %w[ruby lisp haskell]
  end

  example do
    subject.many(/\w/).should == %w[r u b y]
    subject.instance_eval { @input.read }.should == ' lisp haskell'
  end

  example do
    subject.many('else').should == []
    subject.instance_eval { @input.read }.should == 'ruby lisp haskell'
  end
  
  example do
    expect { subject.many1(/\w/) }.should_not raise_error PasParse::Unexpected
    subject.instance_eval { @input.read }.should == ' lisp haskell'
  end

  example do
    expect { subject.many1('else') }.should raise_error PasParse::Unexpected
    subject.instance_eval { @input.read }.should == 'ruby lisp haskell'
  end

  example do
    subject.many1(/\w/).should == %w[r u b y]
    subject.instance_eval { @input.read }.should == ' lisp haskell'
  end
end

describe "#between" do
  
  example do
    lexer = PasParse::Lexer.new StringIO.new '%w[ruby haskell python]'
    lexer.between('%w[', ']') do
      lexer.many do
        lang = lexer.many1(/\w/).join
        lexer.many ' '
        lang
      end
    end.should == %w[ruby haskell python]
    lexer.instance_eval { @input.read }.should == ''
  end

  example do
    lexer = PasParse::Lexer.new StringIO.new '"string"'
    lexer.between('"', '"', 'string').should == "string"
    lexer.instance_eval { @input.read }.should == ''
  end

  example do
    lexer = PasParse::Lexer.new StringIO.new 'unexpected'
    expect { lexer.between('"', '"', "string") }.should raise_error PasParse::Unexpected 
    lexer.instance_eval { @input.read }.should == 'unexpected'
  end
end