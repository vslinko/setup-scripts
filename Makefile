all: root-test vyacheslav dotdeb upgrade-packages install-packages \
	nginx-config www-root

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
	aptitude install -y nginx

nginx-config:
	rm -r /etc/nginx
	cp -r configs/nginx /etc
	service nginx restart

www-root:
        mkdir -p /var/www/rithis.com
	mkdir /var/www/.ssh
	cp configs/authorized_keys /var/www/.ssh
	chown www-data:www-data -R /var/www
	chmod 400 /var/www/.ssh/authorized_keys
	chmod 700 /var/www/.ssh
