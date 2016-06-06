Gem::Specification.new do |s|
  s.name        = 'myst'
  s.version     = '2.0.2'
  s.date        = '2015-02-05'
  s.summary     = 'myst cloud abstraction library'
  s.description = 'A library for talking to vcloud via the java SDK and to Openstack. Needs support Docker/Kubernetes'
  s.platform = 'java'
  s.authors     = ['Tom Bevan', 'Raul Perez', 'Adria Cidre']
  s.email       = 'maintainers@r3labs.io'
  s.files += Dir.glob('lib/**/*')
  s.homepage    = 'http://r3labs.io'
end
