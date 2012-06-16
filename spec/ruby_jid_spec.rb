# encoding: UTF-8

require 'spec_helper'

describe RubyJID do
  it 'handles empty input' do
    [nil, ''].each do |text|
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

  it 'correctly handles domain only jids' do
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
    jid = described_class.new 'alice@wonderland.lit/foo/bar@blarg test'
    jid.node.should be == 'alice'
    jid.domain.should be == 'wonderland.lit'
    jid.resource.should be == 'foo/bar@blarg test'
  end

  it 'accepts separator characters in resource part with missing node part' do
    jid = described_class.new 'wonderland.lit/foo/bar@blarg'
    jid.node.should be_nil
    jid.domain.should be == 'wonderland.lit'
    jid.resource.should be == 'foo/bar@blarg'
    jid.should_not be_domain
  end

  it 'accepts strange characters in node part' do
    jid = described_class.new %q{nasty!#$%()*+,-.;=?[\]^_`{|}~node@example.com}
    jid.node.should be == %q{nasty!#$%()*+,-.;=?[\]^_`{|}~node}
    jid.domain.should be == 'example.com'
    jid.resource.should be_nil
  end

  it 'accepts strange characters in resource part' do
    jid = described_class.new %q{node@example.com/repulsive !#"$%&'()*+,-./:;<=>?@[\]^_`{|}~resource}
    jid.node.should be == 'node'
    jid.domain.should be == 'example.com'
    jid.resource.should be == %q{repulsive !#"$%&'()*+,-./:;<=>?@[\]^_`{|}~resource}
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

  it 'rejects invalid characters' do
    expect { described_class.new %q{alice"s@wonderland.lit} }.to raise_error(ArgumentError)
    expect { described_class.new %q{alice&s@wonderland.lit} }.to raise_error(ArgumentError)
    expect { described_class.new %q{alice's@wonderland.lit} }.to raise_error(ArgumentError)
    expect { described_class.new %q{alice:s@wonderland.lit} }.to raise_error(ArgumentError)
    expect { described_class.new %q{alice<s@wonderland.lit} }.to raise_error(ArgumentError)
    expect { described_class.new %q{alice>s@wonderland.lit} }.to raise_error(ArgumentError)
    expect { described_class.new "alice\u0000s@wonderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new "alice\ts@wonderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new "alice\rs@wonderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new "alice\ns@wonderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new "alice\vs@wonderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new "alice\fs@wonderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new " alice@wonderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new "alice@wonderland.lit " }.to raise_error(ArgumentError)
    expect { described_class.new "alice s@wonderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new "alice@w onderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new "alice@w\tonderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new "alice@w\ronderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new "alice@w\nonderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new "alice@w\vonderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new "alice@w\fonderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new "alice@w\u0000onderland.lit" }.to raise_error(ArgumentError)
    expect { described_class.new "alice@wonderland.lit/\u0000res" }.to raise_error(ArgumentError)
  end
end
