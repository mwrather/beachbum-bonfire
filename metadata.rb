name              "beachbum-bonfire"
maintainer        "Wrather Creative"
maintainer_email  "matt@wrathercreative.com"
license           "GPL"
description       "Configures options for the Beachbum vagrant box for Durpal Dev."
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.1"
recipe            "beachbum-bonfire", "Configures PHP, Apache, MySQL, Pear, and Drush."

%w{ ubuntu debian }.each do |os|
  supports os
end