https://www.namecheap.com/support/knowledgebase/article.aspx/9592/2290/generating-a-csr-on-amazon-web-services-aws/

Generate private key and certificate signing request (CSR):
```
mkdir -p /etc/nginx/ssl
cd /etc/nginx/ssl
sudo openssl genrsa -out rendezvous.private.key 2048
sudo openssl req -new -key rendezvous.private.key -out rendezvous.csr.pem
```
Fill out the requested information.
- US
- Rhode Island
- Providence
- Citroen Rendezvous LLC
- NA
- citroenrendezvous.org
- tim@wordsareimages.com
- (2 blanks)

**Next Steps**
- Copy the CSR and enter it in the CSR field for activation.
- Select the CNAME DNS method for validation
- From the EDIT button, select get record
- Enter the CNAME record in DNS (Hover)

**After receiving the cert from Sectigo via email**
- Unzip the file
- Combine the cert and the bundle:
```
cat citroenrendezvous_org.crt citroenrendezvous_org.ca-bundle > citroenrendezvous_org_chain.crt
```
- Upload the cert
- Move to /etc/nginx/ssl
- Make sure that /etc/nginx/nginx.conf points correctly to the cert and key:
```
    ssl_certificate /etc/nginx/ssl/citroenrendezvous_org_chain.crt;
    ssl_certificate_key /etc/nginx/ssl/rendezvous.private.key;
```