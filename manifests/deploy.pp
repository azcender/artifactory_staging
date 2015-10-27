# Class: tomcat::artifactory
#
# Parameters:
#   name             (String)
#     - The staging of the file to be retrieved
#
#   artifactory_hos  (String)
#     -  The server host name of artifactory
#
#   artifactory_path (String)
#     - The path of the file being retrieved
#
#   artifactory_port (String) [80]
#     - The port the service reside on.
#
# Actions:
#   Installs a file from Artifactory
#
define artifactory_staging::deploy (
  $artifactory_host,
  $artifactory_path,
  $staging,
  $target,
  $artifactory_port = 80,
  $unless = undef,
) {

  include ::staging

  # Validate Maven coordinates and other strings
  validate_string($artifactory_host)
  validate_string($artifactory_path)

  # Validate port is an integer
  validate_integer($artifactory_port)

  # Assign maven repo location
  $artifactory_url = "http://${artifactory_host}:${artifactory_port}/artifactory/${artifactory_path}"

  # Get the checksum of the file being retrieved
  $sha1_url = "http://${artifactory_host}:${artifactory_port}/artifactory/api/storage/${artifactory_path}"

  # Create an unless test for the fetch that compares file and http checksum
  
  # If unless is defined externally use it
  if($unless) {
    $_unless = $unless
  }
  elsif ($artifactory_url =~ /[RELEASE]/) {
    # Use HTTP headers if [RELEASE] block
    $_unless = "test `curl -s -g -I ${artifactory_url} | grep ETag | cut -d : -f 2 | tr -d [:space:]` = `sha1sum ${staging} | cut -d ' ' -f 1 | tr -d '[[:space:]]'`"
  }
  else {
    # Default to standard api capture
    $_unless =
    "test `curl -s ${sha1_url} | grep -i -m 1 sha1 | cut -d '\"' -f 4` = `sha1sum ${staging} | cut -d ' ' -f 1 | tr -d '[[:space:]]'`"
  }

  ::wget::fetch { $artifactory_url:
    destination => $staging,
    unless      => $_unless,
  }

  ::staging::extract { $staging:
    source => $staging,
    target => $target,
  }
}
