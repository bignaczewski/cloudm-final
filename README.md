# README

UCM final project. Copying is not allowed.

Steps to take:

1. create db
2. create application version
3. create env with the specified app and db connection details
4. migrate db
5. delete app
6. delete db

Creation from the terminal:
$ eb create cloudm-env-test3 -db.engine postgres -db.user cloudmadmin -db.pass cloudmadminpass -db.i db.t2.micro --envvars SECRET_KEY_BASE="$(rake secret)" -r eu-west-1
