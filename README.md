ruby_jid
===========

A Ruby representation of an XMPP JID. Provides parsing, validation & accessors.

Install
-------

    gem install ruby_jid

Examples
--------

```ruby
  require 'ruby_jid'

  jid = RubyJID.new 'foo@bar.com'
  jid.node # => "foo"
```

Author
------

Original authors: David Graham, Jeff Smick

Contributors:

* Ben Langfeld

Links
-----
* [Source](https://github.com/benlangfeld/ruby_jid)
* [Documentation](http://rdoc.info/github/benlangfeld/ruby_jid/master/frames)
* [Bug Tracker](https://github.com/benlangfeld/ruby_jid/issues)

Note on Patches/Pull Requests
-----------------------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  * If you want to have your own version, that is fine but bump version in a commit by itself so I can ignore when I pull
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2012 Ben Langfeld, NegativeCode, Jeff Smick. MIT licence (see LICENSE for details).
