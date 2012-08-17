all: root-test vyacheslav dotdeb upgrade-packages install-packages \
	mysql-config php-config nginx-config www-root

root-test:
	@if test `whoami` != "root"; then echo "You must be root"; exit 1; fi

vyacheslav:
	aptitude install -y zsh curl sudo
	cp configs/sudoers /etc/sudoers

	useradd -ms /bin/zsh vyacheslav
	adduser vyacheslav sudo

	mkdir /home/vyacheslav/.ssh
	cp configs/authorized_keys /home/vyacheslav/.ssh

	git clone -n https://github.com/vslinko/dotfiles.git /home/vyacheslav/dotfiles
	mv /home/vyacheslav/dotfiles/.git /home/vyacheslav
	rm -r /home/vyacheslav/dotfiles
	cd /home/vyacheslav && git reset --hard

	chmod 400 /home/vyacheslav/.ssh/authorized_keys
	chmod 700 /home/vyacheslav/.ssh
	chown vyacheslav:vyacheslav -R /home/vyacheslav

dotdeb:
	curl http://www.dotdeb.org/dotdeb.gpg | apt-key add -
	cp configs/dotdeb.list /etc/apt/sources.list.d
	aptitude update

upgrade-packages:
	aptitude upgrade -y

install-packages:
	aptitude install -y nginx php5-apc php5-cli php5-curl php5-fpm php5-gd \
		php5-geoip php5-imagick php5-intl php5-mcrypt php5-memcache \
		php5-memcached php5-mysql php5-pinba php5-sqlite php5-xhprof \
		mysql-server pinba-mysql-5.5

mysql-config:

php-config:
	cp configs/00-php.ini /etc/php5/conf.d
	cp configs/pinba.ini /etc/php5/mods-available
	rm -r /etc/php5/fpm/pool.d
	cp configs/php-fpm.conf /etc/php5/fpm
	service php5-fpm restart

nginx-config:
	rm -r /etc/nginx
	cp -r configs/nginx /etc
	service nginx restart

www-root:
	mkdir -p /var/www/.ssh
	ssh-keygen -q -N "" -C www-data@`hostname` -f /var/www/.ssh/id_rsa
	cp configs/authorized_keys /var/www/.ssh
	ssh-keyscan -t rsa github.com > /var/www/.ssh/known_hosts
	chown www-data:www-data -R /var/www
	chmod 400 /var/www/.ssh/authorized_keys
	chmod 700 /var/www/.ssh
	@echo "\n\nUpload this key to https://github.com/settings/ssh" && cat /var/www/.ssh/id_rsa.pub && echo "\n\n"
