# Application variables

locals {
  app_name                  = "poc-app"
  app_database              = "poc-database"
  app_db_user               = "adminPoc"
  app_db_password           = "password"
  app_db_ssl                = "true"
  app_db_connections        = 5
  app_db_idle_timeout       = 5000
  app_db_connection_timeout = 60000
  app_port                  = 8201
  app_log_level             = "info"
}