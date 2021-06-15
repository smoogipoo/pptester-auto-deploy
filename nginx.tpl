server {
	listen 443 ssl;
	listen [::]:443 ssl;
	server_name {DOMAIN}.((YOUR-DOMAIN-HERE));

	ssl_certificate /etc/nginx/certs/{DOMAIN}.cert;
	ssl_certificate_key /etc/nginx/certs/{DOMAIN}.key;

	location / {
		proxy_pass http://127.0.0.1:{PORT};
		proxy_set_header Host $host;
		proxy_set_header X-Forwarded-For $remote_addr;
	}
}
