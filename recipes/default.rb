# install apt packages
package "git-core"
package "curl"

# custom settings for php.ini
template "/etc/php5/conf.d/custom.ini" do
  source "php.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources("service[apache2]"), :delayed
end

# xdebug package
php_pear "xdebug" do
  action :install
end

# xdebug template
template "/etc/php5/conf.d/xdebug.ini" do
  source "xdebug.ini.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources("service[apache2]"), :delayed
end

# disable default apache site
execute "disable-default-site" do
  command "sudo a2dissite default"
  notifies :reload, resources(:service => "apache2"), :delayed
end

# configure apache project vhost
web_app "project" do
  template "project.conf.erb"
  server_name "beachbum.local"
  docroot "/var/www/drupal"
  set_env node['set_env']
end

# configure pear
execute "pear-discover" do
  command "sudo pear config-set auto_discover 1"
end

execute "pear-upgrade" do
  command "sudo pear upgrade pear"
end

# Install PHPUnit for TDD

execute "pear-discover-phpunit" do
  command "sudo pear channel-discover pear.phpunit.de"
end

execute "phpunit" do
  command "sudo pear install pear.phpunit.de/PHPUnit"
  not_if "phpunit -v | grep PHPUnit"
end

execute "code-sniffer" do
  command "sudo pear install PHP_CodeSniffer"
  not_if "phpcs --version | grep PHP_CodeSniffer"
end

execute "phpcpd" do
  command "sudo pear install pear.phpunit.de/phpcpd"
  not_if "phpcpd -v | grep phpcpd"
end

execute "phploc" do
  command "sudo pear install pear.phpunit.de/phploc"
  not_if "phploc -v | grep phploc"
end

execute "pear-discover-drush" do
  command "sudo pear channel-discover pear.drush.org"
end

execute "drush" do
  command "sudo pear install drush/drush"
end

# This is really hacky. Let's pretend I didn't do it like this.
execute "get-drush-dependencies" do
  command "cd /usr/share/php/drush/lib && sudo curl http://download.pear.php.net/package/Console_Table-1.1.3.tgz | sudo tar -xz"
end

execute "drush-make-beachbum" do
  command "[ -d /var/www/drupal] || [ -f /var/www/beachbum.make ] && drush make /var/www/beachbum.make /var/www/drupal"
end

execute "drush-site-install-beachbum" do
  command "[ -f /var/www/drupal/sites/default/settings.php] || drush -r /var/www/drupal site-install --yes --account-pass=admin --db-su=root --db-su-pw=root --db-url=mysql://root:root@localhost/drupal --site-name=Beachbum"
end
