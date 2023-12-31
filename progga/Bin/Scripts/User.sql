CREATE USER 'socfix'@'localhost'   IDENTIFIED BY 'socfix';
CREATE USER 'socfix'@'127.0.0.1'   IDENTIFIED BY 'socfix';
CREATE USER 'socfix'@'192.168.0.%' IDENTIFIED BY 'socfix';
CREATE USER 'socfix'@'192.168.1.%' IDENTIFIED BY 'socfix';

GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, LOCK TABLES ON SocFix.* TO 'socfix'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, LOCK TABLES ON SocFix.* TO 'socfix'@'127.0.0.1';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, LOCK TABLES ON SocFix.* TO 'socfix'@'192.168.0.%';
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE, LOCK TABLES ON SocFix.* TO 'socfix'@'192.168.1.%';

FLUSH PRIVILEGES;