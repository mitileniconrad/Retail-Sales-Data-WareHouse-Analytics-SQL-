
-- The API connects with this user, so it can read data but never change it.

CREATE USER api_viewer WITH PASSWORD = 'PassLetter1234@';
ALTER ROLE db_datareader ADD MEMBER api_viewer;