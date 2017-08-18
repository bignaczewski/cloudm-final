# README

UCM final project (Ruby on Rails). Copying is not allowed.

Description: The goal of this work is to create an integrator that makes the communication with cloud provider(s) (Amazon in this case) as easy and quick as possible, aiming to be used even by non-technical users. It supports the full process of application deployment and termination along with cloud-based database management, what drastically lowers the time needed to set up the infrastructure.

--------------------------------------------

The project consists of two main panels: end users and administrator panel. The first one is designed to be used only by „real” application users, whereas an administrator can change application settings, connect with the cloud and create an infrastructure to support it.
Due to being limited to a free tier all calls are synchronous and (unfortunately) no background processing is being used.
There are no tests as they were not required by university. If they were, VCR cassettes for requests would be recorded.
Please, keep in mind that it is only a prototype.

--------------------------------------------

To run the project locally, remember to put your keys in config/secret.json:

{
  "access_key_id":"XXX",
  "secret_access_key":"YYY"
}

--------------------------------------------

Steps to take from the admin panel to fully deploy, migrate and delete the app:

1. create db
2. create application version
3. create env with the specified app and db connection details
4. migrate db
5. delete app
6. delete db

--------------------------------------------

Creation from the terminal:
$ eb create cloudm-env-test3 -db.engine postgres -db.user cloudmadmin -db.pass cloudmadminpass -db.i db.t2.micro --envvars SECRET_KEY_BASE="$(rake secret)" -r eu-west-1
