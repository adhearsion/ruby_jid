# encoding: UTF-8

require 'spec_helper'

describe RubyJID do
  it 'handles empty input' do
    [nil, ''].each do |text|
      described_class.valid?(text).should be_true
      jid = described_class.new text
      jid.node.should be_nil
      jid.resource.should be_nil
      jid.domain.should be == ''
      jid.to_s.should be == ''
      jid.bare.to_s.should be == ''
      jid.should be_empty
      jid.should_not be_domain
    end
  end

  it 'raises when a jid part is too long' do
    expect { described_class.new('n' * 1023) }.to_not raise_error
    expect { described_class.new('n' * 1023, 'd' * 1023, 'r' * 1023) }.to_not raise_error

    expect { described_class.new('n' * 1024) }.to raise_error(ArgumentError)
    expect { described_class.new('n', 'd' * 1024) }.to raise_error(ArgumentError)
    expect { described_class.new('n', 'd', 'r' * 1024) }.to raise_error(ArgumentError)
  end

  it 'validates JID strings based on length' do
    described_class.valid?('n' * 1023).should be_true
    described_class.valid?('n' * 1023, 'd' * 1023, 'r' * 1023).should be_true

    described_class.valid?('n' * 1024).should be_false
    described_class.valid?('n', 'd' * 1024).should be_false
    described_class.valid?('n', 'd', 'r' * 1024).should be_false
  end

  it 'correctly handles domain only jids' do
    described_class.valid?('wonderland.lit').should be_true
    jid = described_class.new 'wonderland.lit'
    jid.to_s.should be == 'wonderland.lit'
    jid.domain.should be == 'wonderland.lit'
    jid.node.should be_nil
    jid.resource.should be_nil
    jid.bare.should be == jid
    jid.should be_domain
    jid.should_not be_empty
  end

  it 'correctly handles bare jid components' do
    jid = described_class.new 'alice', 'wonderland.lit'
    jid.to_s.should be == 'alice@wonderland.lit'
    jid.domain.should be == 'wonderland.lit'
    jid.node.should be == 'alice'
    jid.resource.should be_nil
    jid.bare.should be == jid
    jid.should_not be_domain
    jid.should_not be_empty
  end

  it 'correctly parses bare jids' do
    described_class.valid?('alice@wonderland.lit').should be_true
    jid = described_class.new 'alice@wonderland.lit'
    jid.to_s.should be == 'alice@wonderland.lit'
    jid.domain.should be == 'wonderland.lit'
    jid.node.should be == 'alice'
    jid.resource.should be_nil
    jid.bare.should be == jid
    jid.should_not be_domain
    jid.should_not be_empty
  end

  it 'correctly handles full jid components' do
    jid = described_class.new 'alice', 'wonderland.lit', 'tea'
    jid.to_s.should be == 'alice@wonderland.lit/tea'
    jid.domain.should be == 'wonderland.lit'
    jid.node.should be == 'alice'
    jid.resource.should be == 'tea'
    jid.bare.should_not be == jid
    jid.should_not be_domain
    jid.should_not be_empty
  end

  it 'correctly parses full jids' do
    described_class.valid?('alice@wonderland.lit/tea').should be_true
    jid = described_class.new 'alice@wonderland.lit/tea'
    jid.to_s.should be == 'alice@wonderland.lit/tea'
    jid.domain.should be == 'wonderland.lit'
    jid.node.should be == 'alice'
    jid.resource.should be == 'tea'
    jid.bare.should_not be == jid
    jid.should_not be_domain
    jid.should_not be_empty
  end

  it 'accepts separator characters in resource part' do
    described_class.valid?('alice@wonderland.lit/foo/bar@blarg test').should be_true
    jid = described_class.new 'alice@wonderland.lit/foo/bar@blarg test'
    jid.node.should be == 'alice'
    jid.domain.should be == 'wonderland.lit'
    jid.resource.should be == 'foo/bar@blarg test'
  end

  it 'accepts separator characters in resource part with missing node part' do
    described_class.valid?('wonderland.lit/foo/bar@blarg').should be_true
    jid = described_class.new 'wonderland.lit/foo/bar@blarg'
    jid.node.should be_nil
    jid.domain.should be == 'wonderland.lit'
    jid.resource.should be == 'foo/bar@blarg'
    jid.should_not be_domain
  end

  it 'accepts strange characters in node part' do
    string = %q{nasty!#$%()*+,-.;=?[\]^_`{|}~node@example.com}
    described_class.valid?(string).should be_true
    jid = described_class.new string
    jid.node.should be == %q{nasty!#$%()*+,-.;=?[\]^_`{|}~node}
    jid.domain.should be == 'example.com'
    jid.resource.should be_nil
  end

  it 'accepts strange characters in resource part' do
    string = %q{node@example.com/repulsive !#"$%&'()*+,-./:;<=>?@[\]^_`{|}~resource}
    described_class.valid?(string).should be_true
    jid = described_class.new string
    jid.node.should be == 'node'
    jid.domain.should be == 'example.com'
    jid.resource.should be == %q{repulsive !#"$%&'()*+,-./:;<=>?@[\]^_`{|}~resource}
  end

  it 'maintains node and resource case, but downcases the domain' do
    described_class.valid?("Foo@Bar.com/Baz").should be_true
    jid = described_class.new "Foo@Bar.com/Baz"
    jid.node.should be == 'Foo'
    jid.domain.should be == 'bar.com'
    jid.resource.should be == 'Baz'
    jid.to_s.should be == 'Foo@bar.com/Baz'
  end

  it 'compares case insensitively' do
    jid1 = described_class.new "Foo@Bar.com/Baz"
    jid2 = described_class.new "foo@bar.com/baz"
    jid3 = described_class.new "Foo@Bar.com/other"
    jid1.should be == jid2
    jid1.should_not be == jid3
  end

  it 'rejects empty jid parts' do
    expect { described_class.new '@wonderland.lit' }.to raise_error(ArgumentError)
    expect { described_class.new 'wonderland.lit/' }.to raise_error(ArgumentError)
    expect { described_class.new '@' }.to raise_error(ArgumentError)
    expect { described_class.new 'alice@' }.to raise_error(ArgumentError)
    expect { described_class.new '/' }.to raise_error(ArgumentError)
    expect { described_class.new '/res' }.to raise_error(ArgumentError)
    expect { described_class.new '@/' }.to raise_error(ArgumentError)
  end

  let :invalid_jids do
    [
      %q{alice"s@wonderland.lit},
      %q{alice&s@wonderland.lit},
      %q{alice's@wonderland.lit},
      %q{alice:s@wonderland.lit},
      %q{alice<s@wonderland.lit},
      %q{alice>s@wonderland.lit},
      "alice\u0000s@wonderland.lit",
      "alice\ts@wonderland.lit",
      "alice\rs@wonderland.lit",
      "alice\ns@wonderland.lit",
      "alice\vs@wonderland.lit",
      "alice\fs@wonderland.lit",
      " alice@wonderland.lit",
      "alice@wonderland.lit ",
      "alice s@wonderland.lit",
      "alice@w onderland.lit",
      "alice@w\tonderland.lit",
      "alice@w\ronderland.lit",
      "alice@w\nonderland.lit",
      "alice@w\vonderland.lit",
      "alice@w\fonderland.lit",
      "alice@w\u0000onderland.lit",
      "alice@wonderland.lit/\u0000res"
    ]
  end

  it 'rejects invalid characters' do
    invalid_jids.each do |jid|
      expect { described_class.new jid }.to raise_error(ArgumentError)
    end
  end

  it 'validates invalid JID strings as false' do
    invalid_jids.each do |jid|
      described_class.valid?(jid).should be_false
    end
  end
end
