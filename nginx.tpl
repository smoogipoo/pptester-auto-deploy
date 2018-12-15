server {
	listen 80;
	listen [::]:80;
	server_name {DOMAIN}.((YOUR-DOMAIN-HERE));

	location / {
		proxy_pass http://127.0.0.1:{PORT};
		proxy_set_header Host $host;
		proxy_set_header X-Forwarded-For $remote_addr;
	}
}
