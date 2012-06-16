# encoding: UTF-8

require "ruby_jid/version"

# Jabber ID or JID
#
# See [RFC 3920 Section 3 - Addressing](http://xmpp.org/rfcs/rfc3920.html#addressing)
#
# An entity is anything that can be considered a network endpoint (i.e., an
# ID on the network) and that can communicate using XMPP. All such entities
# are uniquely addressable in a form that is consistent with RFC 2396 [URI].
# For historical reasons, the address of an XMPP entity is called a Jabber
# Identifier or JID. A valid JID contains a set of ordered elements formed
# of a domain identifier, node identifier, and resource identifier.
#
# The syntax for a JID is defined below using the Augmented Backus-Naur Form
# as defined in [ABNF]. (The IPv4address and IPv6address rules are defined
# in Appendix B of [IPv6]; the allowable character sequences that conform to
# the node rule are defined by the Nodeprep profile of [STRINGPREP] as
# documented in Appendix A of this memo; the allowable character sequences
# that conform to the resource rule are defined by the Resourceprep profile
# of [STRINGPREP] as documented in Appendix B of this memo; and the
# sub-domain rule makes reference to the concept of an internationalized
# domain label as described in [IDNA].)
#
#     jid             = [ node "@" ] domain [ "/" resource ]
#     domain          = fqdn / address-literal
#     fqdn            = (sub-domain 1*("." sub-domain))
#     sub-domain      = (internationalized domain label)
#     address-literal = IPv4address / IPv6address
#
# All JIDs are based on the foregoing structure. The most common use of this
# structure is to identify an instant messaging user, the server to which
# the user connects, and the user's connected resource (e.g., a specific
# client) in the form of <user@host/resource>. However, node types other
# than clients are possible; for example, a specific chat room offered by a
# multi-user chat service could be addressed as <room@service> (where "room"
# is the name of the chat room and "service" is the hostname of the
# multi-user chat service) and a specific occupant of such a room could be
# addressed as <room@service/nick> (where "nick" is the occupant's room
# nickname). Many other JID types are possible (e.g., <domain/resource>
# could be a server-side script or service).
#
# Each allowable portion of a JID (node identifier, domain identifier, and
# resource identifier) MUST NOT be more than 1023 bytes in length, resulting
# in a maximum total size (including the '@' and '/' separators) of 3071
# bytes.
class RubyJID
  include Comparable

  PATTERN = /\A(?:([^@]*)@)??([^@\/]*)(?:\/(.*?))?\Z/.freeze

  # http://tools.ietf.org/html/rfc6122#appendix-A
  NODE_PREP = /[[:cntrl:] "&'\/:<>@]/.freeze

  # http://tools.ietf.org/html/rfc3454#appendix-C
  NAME_PREP = /[[:cntrl:] ]/.freeze

  # http://tools.ietf.org/html/rfc6122#appendix-B
  RESOURCE_PREP = /[[:cntrl:]]/.freeze

  attr_reader :node, :domain, :resource
  attr_writer :resource

  # @private
  def self.new(node, domain = nil, resource = nil)
    node.is_a?(RubyJID) ? node : super
  end

  # Validate a JID
  #
  # @return [Boolean] true if a valid JID, otherwise false
  def self.valid?(node, domain = nil, resource = nil)
    !!new(node, domain, resource)
  rescue ArgumentError
    false
  end

  # Create a new JID object
  #
  # @overload initialize(jid)
  #   Passes the jid object right back out
  #   @param [RubyJID] jid a jid object
  # @overload initialize(jid)
  #   Creates a new JID parsed out of the provided jid
  #   @param [String] jid a jid in the standard format
  #   ("node@domain/resource")
  # @overload initialize(node, domain = nil, resource = nil)
  #   Creates a new JID
  #   @param [String] node the node of the JID
  #   @param [String, nil] domian the domain of the JID
  #   @param [String, nil] resource the resource of the JID
  # @raise [ArgumentError] if the parts of the JID are too large (1023 bytes)
  # @return [RubyJID] a new jid object
  def initialize(node, domain = nil, resource = nil)
    @node, @domain, @resource = node, domain, resource

    if @domain.nil? && @resource.nil?
      @node, @domain, @resource = @node.to_s.scan(PATTERN).first
    end
    @domain.downcase! if @domain

    validate
  end

  # Strip the resource part from this JID and return it as a new
  # JID object. The new JID contains only the optional node part
  # and the required domain part from the original. This JID remains
  # unchanged.
  #
  # @return [RubyJID] a new JID without a resource
  def bare
    RubyJID.new @node, @domain
  end

  # Return true if this is a bare JID without a resource part.
  def bare?
    @resource.nil?
  end

  # Return true if this is a domain-only JID without a node or resource part.
  def domain?
    !empty? && to_s == @domain
  end

  # Return true if this JID is equal to the empty string ''. That is, it's
  # missing the node, domain, and resource parts that form a valid JID. It
  # makes for easier error handling to be able to create JID objects from
  # strings and then check if they're empty rather than nil.
  def empty?
    to_s == ''
  end

  def <=>(jid)
    to_s.downcase <=> jid.to_s.downcase
  end

  def eql?(jid)
    jid.is_a?(RubyJID) && self == jid
  end

  def hash
    to_s.hash
  end

  # Turn the JID into a string
  #
  # * ""
  # * "domain"
  # * "node@domain"
  # * "domain/resource"
  # * "node@domain/resource"
  #
  # @return [String] the JID as a string
  def to_s
    s = @domain
    s = "#{@node}@#{s}" if @node
    s = "#{s}/#{@resource}" if @resource
    s
  end

  private

  def validate
    [@node, @domain, @resource].each do |part|
      raise ArgumentError, 'jid too long' if (part || '').size > 1023
    end
    raise ArgumentError, 'empty node' if @node && @node.strip.empty?
    raise ArgumentError, 'node contains invalid characters' if @node && @node =~ NODE_PREP
    raise ArgumentError, 'empty resource' if @resource && @resource.strip.empty?
    raise ArgumentError, 'resource contains invalid characters' if @resource && @resource =~ RESOURCE_PREP
    raise ArgumentError, 'empty domain' if @domain == '' && (@node || @resource)
    raise ArgumentError, 'domain contains invalid characters' if @domain && @domain =~ NAME_PREP
  end
end
