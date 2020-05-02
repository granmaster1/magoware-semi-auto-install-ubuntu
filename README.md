## Why am I doing this?
For those of you that don't know, Magoware is a middleman IPTV management solution that's very similar to Ministra. 
I'd like to say its used by thousands of people around the world but honestly i don't think it is. Frankly its utter garbage! but who am I to not give the people (Shailendra) what they want.
**But honestly, there is very little documentation out there, the software is buggy like you wouldn't believe and installation without scripts like this are a bitch....**
## Notes on the installation.
If your desperate enough to want to install Magoware then there are a few things you need to get sorted which unfortunately my script can't do for you (I'm tired). 
* Set up an SMTP Server - to do this use something like Mailgun.
* Set up Certbot/Letsencrypt certificates.
Once you have the above sorted your ready to go. 
## The Script.
The script will do 99% of the leg work for you and Semi Auto install Magoware on Ubuntu 18 or Ubuntu 20.04. 
## Get the Script.
```
cd ~
git clone https://gitlab.com/Sutherland/magoware-semi-auto-install-ubuntu.git
```
## Run the Script.
```
cd magoware-semi-auto-install-ubuntu
sudo bash ./auto-magoware.sh
```
During the installation you will be asked to supply a password for MySQL & Redis Server. Once the script has finished continue with the following steps. 
## Finishing Touches.
Edit the **production.js** file and add the https certificates as shown below. 
```
nano /usr/local/src/magoware/config/env/production.js
```
Edit https certificate details as shown below. 
```
    privateKey: '<PATH TO PRIVKEY.PEM>',
    certificate: '<PATH TO CERT.PEM>',
    ca: '<PATH TO CHAIN.PEM'
```
Whilst your there you can add the SMTP details. 
* Change **MAILER_FROM** to email address that Magoware will be sending emails from.
* **MAILER_SERVICE_PROVIDER** to SMTP server address. 
* **MAILER_EMAIL_ID** will be the same as MAILER_FROM.
* **MAILER_PASSWORD** to the password required for Magoware to send emails. 
```
  mailer: {
    from: process.env.MAILER_FROM || 'MAILER_FROM',
    options: {
      service: process.env.MAILER_SERVICE_PROVIDER || 'MAILER_SERVICE_PROVIDER',
      auth: {
        user: process.env.MAILER_EMAIL_ID || 'MAILER_EMAIL_ID',
        pass: process.env.MAILER_PASSWORD || 'MAILER_PASSWORD'
      }
    }
  }
 ```
Once you are done do `CTRL + O` to save and `CTRL + X` to close Nano.
## First Start.
To run Magoware for the first time you have to run 
```
sudo node /usr/local/src/magoware/server.js
```
You will be asked for. 
* database username this will be `root`.
* database password this will be the password you entered when running my script.
* database host this will be `localhost`.
* database name this will be `magoware`.

You will likely see a ton of errors after you have entered the information above, this is because no data exists in the database. Leave it a minute and the database will be populated with the details for the root company. 
Administrator panel will be available at `https://<YOUR DOMAIN>/admin`. The default username is `superadmin` and the default password is `superadmin`
## A Tip For You.
The first thing your going to need to do after you login is create a company, to do this you'd think you go into company settings.. haha!. Magoware don't make it this easy... the software will hang and sit there forever. Instead open this URL. 
```
https://<YOUR DOMAIN>/admin/#/company_settings/create
```
Enter the details for your new company, make sure you enter the same SMTP details that you entered into `production.js` earlier and an email address to create your superuser account with. Once you click Create it should send you an email asking you to join Magoware... That's your way in. you can change the password on the `superadmin` account and forget it existed. 
If you read this and you would like to give any feedback or discuss the script any further, please email sutherland@scripting.online.
